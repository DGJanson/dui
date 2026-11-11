package dui

import "core:testing"
import rl "vendor:raylib"

@(test)
test_textarea_allocation_and_cleanup :: proc(t: ^testing.T) {
    style := create_simple_style()
    // overwrite fontsize so our calcs will work out :)
    style.fontsize = 10

    ta := textarea_generate(
        bounds = rl.Rectangle{0, 0, 120, 100},
        pad_horizontal = 10,
        pad_vertical = 10,
        text = "Hello World\nSecond Line\r\nLong Line That is",
        style = &style,
        allocator = context.allocator,
    )

    // Check pre-calcs
    testing.expect_value(t, len(ta.lines), 4)
    testing.expect_value(t, string(ta.lines[0]), "Hello World")
    testing.expect_value(t, string(ta.lines[1]), "Second Line")
    testing.expect_value(t, string(ta.lines[2]), "Long Line That")

    // Update text and recheck
    textarea_update_text(&ta, "Hello World\nSecond Line", context.allocator)

    testing.expect_value(t, len(ta.lines), 2)
    testing.expect_value(t, string(ta.lines[0]), "Hello World")
    testing.expect_value(t, string(ta.lines[1]), "Second Line")

    // Free memory
    textarea_destroy(&ta, context.allocator)
}

@(test)
test_textarea_empty_string :: proc(t: ^testing.T) {
    style := create_simple_style()

    ta := textarea_generate(rl.Rectangle{0, 0, 100, 100}, 0, 0, "", &style)
    defer textarea_destroy(&ta)

    testing.expect_value(t, len(ta.lines), 0)
}

@(test)
test_textarea_hardwrap :: proc(t: ^testing.T) {
    style := create_simple_style()

    ta := textarea_generate(rl.Rectangle{0, 0, 100, 100}, 0, 0, "EenLangWoordDatErgensWordtGesplitst", &style)
    defer (textarea_destroy(&ta))

    testing.expect_value(t, len(ta.lines), 4)
    testing.expect_value(t, string(ta.lines[0]), "EenLangWoo")
}