package dui

import "core:strings"
import "core:unicode/utf8"
import rl "vendor:raylib"

// TODO this is completely LLM generated
// Update as we go.

TextBox :: struct {
    bounds:     rl.Rectangle,
    buffer:     [dynamic]u8,
    cursor:     int, // Byte index in buffer
    is_focused: bool,
    style:      ^DuiStyle,
}

textbox_create :: proc(bounds: rl.Rectangle, style: ^DuiStyle, allocator := context.allocator) -> TextBox {
    return TextBox {
        bounds = bounds,
        buffer = make([dynamic]u8, allocator),
        cursor = 0,
        is_focused = false,
        style = style,
    }
}

textbox_destroy :: proc(tb: ^TextBox) {
    delete(tb.buffer)
}

textbox_update :: proc(tb: ^TextBox) {
    // Check focus on mouse click
    mouse_pos := rl.GetMousePosition()
    if rl.IsMouseButtonPressed(.LEFT) {
        tb.is_focused = rl.CheckCollisionPointRec(mouse_pos, tb.bounds)
    }

    if !tb.is_focused do return

    // 1. Handle character input (typing)
    char := rl.GetCharPressed()
    for char > 0 {
        // Only accept printable characters (>= 32)
        if char >= 32 {
            b, w := utf8.encode_rune(char)
            // Inject bytes at cursor position
            for i in 0 ..< w {
                inject_at(&tb.buffer, tb.cursor + i, b[i])
            }
            tb.cursor += w
        }
        char = rl.GetCharPressed()
    }

    // 2. Handle Backspace (repeats when held)
    if (rl.IsKeyPressedRepeat(.BACKSPACE) || rl.IsKeyPressed(.BACKSPACE)) && tb.cursor > 0 {
        // Find previous UTF-8 rune boundary
        prev_cursor := tb.cursor - 1
        for prev_cursor > 0 && (tb.buffer[prev_cursor] & 0xC0) == 0x80 {
            prev_cursor -= 1
        }
        bytes_to_remove := tb.cursor - prev_cursor
        for _ in 0 ..< bytes_to_remove {
            ordered_remove(&tb.buffer, prev_cursor)
        }
        tb.cursor = prev_cursor
    }

    // 3. Handle Arrow Keys
    if (rl.IsKeyPressedRepeat(.LEFT) || rl.IsKeyPressed(.LEFT)) && tb.cursor > 0 {
        tb.cursor -= 1
        for tb.cursor > 0 && (tb.buffer[tb.cursor] & 0xC0) == 0x80 {
            tb.cursor -= 1
        }
    }
    if (rl.IsKeyPressedRepeat(.RIGHT) || rl.IsKeyPressed(.RIGHT)) && tb.cursor < len(tb.buffer) {
        tb.cursor += 1
        for tb.cursor < len(tb.buffer) && (tb.buffer[tb.cursor] & 0xC0) == 0x80 {
            tb.cursor += 1
        }
    }
}

textbox_draw :: proc(tb: ^TextBox) {
    // Draw box background & border
    border_color := tb.is_focused ? tb.style.colors.purple : tb.style.colors.fg
    rl.DrawRectangleRec(tb.bounds, tb.style.colors.bg)
    rl.DrawRectangleLinesEx(tb.bounds, 1, border_color)

    // Convert current buffer to cstring using temp allocator
    text_str := string(tb.buffer[:])
    text_c := strings.clone_to_cstring(text_str, context.temp_allocator)

    text_pos := rl.Vector2{tb.bounds.x + 6, tb.bounds.y + (tb.bounds.height - tb.style.fontsize) / 2}
    rl.DrawTextEx(tb.style.font, text_c, text_pos, tb.style.fontsize, 0, tb.style.colors.fg)

    // Draw blinking cursor when focused
    if tb.is_focused {
        // Measure text up to cursor position to know where to draw vertical bar
        text_before_cursor := string(tb.buffer[:tb.cursor])
        c_before := strings.clone_to_cstring(text_before_cursor, context.temp_allocator)
        cursor_offset := rl.MeasureTextEx(tb.style.font, c_before, tb.style.fontsize, 0).x

        // Blink cursor every half second
        time_sec := rl.GetTime()
        if int(time_sec * 2) % 2 == 0 {
            cursor_x := text_pos.x + cursor_offset
            rl.DrawLineEx(
                rl.Vector2{cursor_x, text_pos.y},
                rl.Vector2{cursor_x, text_pos.y + tb.style.fontsize},
                1.5,
                tb.style.colors.fg,
            )
        }
    }
}