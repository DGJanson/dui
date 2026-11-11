package dui

import "base:runtime"
import rl "vendor:raylib"

// struct for generating textareas
// it will automatically wrap
// and only render inside its "rectangle"
// Note that it is possible to update text,
// but not size
TextArea :: struct {
    bounds:         rl.Rectangle,
    pad_horizontal: f32,
    pad_vertical:   f32,
    max_chars:      int, // save the max chars, for further calcs
    buffer:         []u8, // to store string data
    lines:          []cstring, // pointer to each line
    style:          ^DuiStyle,
    color:          rl.Color,
}

// Generate a textarea struct
// You need to do this once for each text
// It will calc linebreaks for wrapping and the like
// then you can call the draw procedure each draw loop
// Do NOT use the same temp allocator as you use in the draw loop
// since the struct will likely persist over multiple loops
textarea_generate :: proc(
    bounds: rl.Rectangle,
    pad_horizontal, pad_vertical: f32,
    text: string,
    style: ^DuiStyle,
    allocator: runtime.Allocator = context.allocator,
) -> TextArea {

    // Determine available width inside text box
    available_width := bounds.width - 2 * pad_horizontal
    if available_width <= 0 {
        available_width = bounds.width
    }

    // Assume monospace font: calculate width of a single character
    char_size := rl.MeasureTextEx(style.font, "M", style.fontsize, 0)
    char_width := char_size.x
    if char_width <= 0 {
        char_width = style.fontsize * 0.6
    }

    max_chars := int(available_width / char_width)
    if max_chars < 1 {
        max_chars = 1
    }

    buffer, lines := textarea_parse_text(text, max_chars, allocator)

    return TextArea {
        bounds = bounds,
        pad_horizontal = pad_horizontal,
        pad_vertical = pad_vertical,
        max_chars = max_chars,
        buffer = buffer,
        lines = lines,
        style = style,
        color = style.colors.fg,
    }
}

textarea_parse_text :: proc(text: string, max_chars: int, allocator: runtime.Allocator) -> ([]u8, []cstring) {
    // Pass 1: Find line breaks and store slices in temporary storage
    line_list := make([dynamic]string, context.temp_allocator)

    idx := 0
    for idx < len(text) {
        // Handle standalone newline or carriage return
        if text[idx] == '\n' {
            append(&line_list, "")
            idx += 1
            continue
        }
        if text[idx] == '\r' {
            if idx + 1 < len(text) && text[idx + 1] == '\n' {
                append(&line_list, "")
                idx += 2
            } else {
                append(&line_list, "")
                idx += 1
            }
            continue
        }

        limit := min(len(text), idx + max_chars)

        // Check for explicit newline within the current line segment
        nl_idx := -1
        for i in idx ..< limit {
            if text[i] == '\n' || text[i] == '\r' {
                nl_idx = i
                break
            }
        }

        if nl_idx != -1 {
            // exclude the linebreak
            append(&line_list, text[idx:nl_idx])
            if text[nl_idx] == '\r' && nl_idx + 1 < len(text) && text[nl_idx + 1] == '\n' {
                idx = nl_idx + 2
            } else {
                idx = nl_idx + 1
            }
            continue
        }

        // Entire remainder fits into this line
        if limit == len(text) {
            append(&line_list, text[idx:limit])
            break
        }

        // Softwrap boundary: check if boundary lands on whitespace or newline
        if text[limit] == '\n' {
            append(&line_list, text[idx:limit])
            idx = limit + 1
            continue
        }
        if text[limit] == '\r' {
            append(&line_list, text[idx:limit + 1])
            if limit + 1 < len(text) && text[limit] == '\n' {
                idx = limit + 2
            } else {
                idx = limit + 1
            }
            continue
        }
        if text[limit] == ' ' {
            append(&line_list, text[idx:limit])
            idx = limit + 1
            continue
        }

        // Try breaking at the last space in the line
        last_space := -1
        for i := limit - 1; i > idx; i -= 1 {
            if text[i] == ' ' || text[i] == '\t' {
                last_space = i
                break
            }
        }

        if last_space > idx {
            append(&line_list, text[idx:last_space])
            idx = last_space + 1
        } else {
            // No whitespace to break on, hard break at limit
            append(&line_list, text[idx:limit])
            idx = limit
        }
    }

    // Pass 2: Allocate backing buffer and lines array
    total_bytes := 0
    for line in line_list {
        total_bytes += len(line) + 1 // + 1 for null terminator
    }

    buffer := make([]u8, total_bytes, allocator)
    lines := make([]cstring, len(line_list), allocator)

    curr_offset := 0
    for line, i in line_list {
        copy(buffer[curr_offset:], line)
        buffer[curr_offset + len(line)] = 0
        lines[i] = cstring(&buffer[curr_offset])
        curr_offset += len(line) + 1
    }

    return buffer, lines
}

// Set new text for textarea
// The text will be reparsed completely!
textarea_update_text :: proc(textarea: ^TextArea, new_text: string, allocator: runtime.Allocator = context.allocator) {
    if textarea == nil do return

    // First clear the current buffer and lines
    delete(textarea.buffer, allocator)
    delete(textarea.lines, allocator)
    textarea.buffer = nil
    textarea.lines = nil

    // Now recalc buffer and lines based on new string
    buffer, lines := textarea_parse_text(new_text, textarea.max_chars, allocator)
    textarea.buffer = buffer
    textarea.lines = lines
}

textarea_destroy :: proc(textarea: ^TextArea, allocator: runtime.Allocator = context.allocator) {
    if textarea == nil do return
    delete(textarea.buffer, allocator)
    delete(textarea.lines, allocator)
    textarea.buffer = nil
    textarea.lines = nil
}

textarea_draw :: proc(textarea: ^TextArea) {
    if textarea == nil do return

    line_height := textarea.style.fontsize
    char_size := rl.MeasureTextEx(textarea.style.font, "M", textarea.style.fontsize, 0)
    if char_size.y > 0 {
        line_height = char_size.y
    }

    for line, i in textarea.lines {
        pos := rl.Vector2 {
            textarea.bounds.x + textarea.pad_horizontal,
            textarea.bounds.y + textarea.pad_vertical + f32(i) * line_height,
        }
        if pos.y + line_height > textarea.bounds.y + textarea.bounds.height {
            // Do NOT draw overflow
            return
        }
        rl.DrawTextEx(textarea.style.font, line, pos, textarea.style.fontsize, 0, textarea.color)
    }
}

