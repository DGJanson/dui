package dui

import "core:testing"
import rl "vendor:raylib"

@(test)
test_split_function :: proc(t: ^testing.T) {
    base_rect := rl.Rectangle{10, 10, 120, 120}

    left, right := rect_split_horizontally(base_rect, 0.5)
    testing.expect_value(t, left.x, 10)
    testing.expect_value(t, right.x, 70)
    testing.expect_value(t, left.width, 60)
    testing.expect_value(t, right.width, 60)

    left, right = rect_split_horizontally(base_rect, 5 / 6.0)
    testing.expect_value(t, left.x, 10)
    testing.expect_value(t, right.x, 110)
    testing.expect_value(t, left.width, 100)
    testing.expect_value(t, right.width, 20)

    top, bottom := rect_split_vertically(base_rect, 0.333333333)
    testing.expect_value(t, bottom.x, 10)
    testing.expect_value(t, bottom.y, 50)
    testing.expect_value(t, top.width, 120)
    testing.expect_value(t, bottom.height, 80)

    top, bottom = rect_split_vertically(base_rect, -1)
    testing.expect_value(t, bottom.x, 10)
    testing.expect_value(t, bottom.y, 10)
    testing.expect_value(t, top.width, 120)
    testing.expect_value(t, bottom.height, 120)
}

@(test)
test_rect_cuts :: proc(t: ^testing.T) {
    base_rect := rl.Rectangle{10, 20, 100, 80}

    left, rest_left := rect_cut_left(base_rect, 30)
    testing.expect_value(t, left.x, 10)
    testing.expect_value(t, left.y, 20)
    testing.expect_value(t, left.width, 30)
    testing.expect_value(t, left.height, 80)
    testing.expect_value(t, rest_left.x, 40)
    testing.expect_value(t, rest_left.y, 20)
    testing.expect_value(t, rest_left.width, 70)
    testing.expect_value(t, rest_left.height, 80)

    right, rest_right := rect_cut_right(base_rect, 30)
    testing.expect_value(t, right.x, 80)
    testing.expect_value(t, right.y, 20)
    testing.expect_value(t, right.width, 30)
    testing.expect_value(t, right.height, 80)
    testing.expect_value(t, rest_right.x, 10)
    testing.expect_value(t, rest_right.y, 20)
    testing.expect_value(t, rest_right.width, 70)
    testing.expect_value(t, rest_right.height, 80)

    top, rest_top := rect_cut_top(base_rect, 25)
    testing.expect_value(t, top.x, 10)
    testing.expect_value(t, top.y, 20)
    testing.expect_value(t, top.width, 100)
    testing.expect_value(t, top.height, 25)
    testing.expect_value(t, rest_top.x, 10)
    testing.expect_value(t, rest_top.y, 45)
    testing.expect_value(t, rest_top.width, 100)
    testing.expect_value(t, rest_top.height, 55)

    bottom, rest_bottom := rect_cut_bottom(base_rect, 25)
    testing.expect_value(t, bottom.x, 10)
    testing.expect_value(t, bottom.y, 75)
    testing.expect_value(t, bottom.width, 100)
    testing.expect_value(t, bottom.height, 25)
    testing.expect_value(t, rest_bottom.x, 10)
    testing.expect_value(t, rest_bottom.y, 20)
    testing.expect_value(t, rest_bottom.width, 100)
    testing.expect_value(t, rest_bottom.height, 55)
}

@(test)
test_rect_get_center :: proc(t: ^testing.T) {
    base_rect := rl.Rectangle{10, 20, 100, 80}

    // Normal centering
    center := rect_get_center(base_rect, 40, 20)
    testing.expect_value(t, center.x, 40)
    testing.expect_value(t, center.y, 50)
    testing.expect_value(t, center.width, 40)
    testing.expect_value(t, center.height, 20)

    // Oversized centering (clamps to base rect dimensions)
    oversized := rect_get_center(base_rect, 150, 100)
    testing.expect_value(t, oversized.x, 10)
    testing.expect_value(t, oversized.y, 20)
    testing.expect_value(t, oversized.width, 100)
    testing.expect_value(t, oversized.height, 80)
}

@(test)
test_rect_pad :: proc(t: ^testing.T) {
    base_rect := rl.Rectangle{10, 10, 100, 80}

    padded := rect_pad(base_rect, 5, 15, 10, 20)
    testing.expect_value(t, padded.x, 20)
    testing.expect_value(t, padded.y, 15)
    testing.expect_value(t, padded.width, 70)
    testing.expect_value(t, padded.height, 60)

    // Padding exceeds dimensions
    excess_padded := rect_pad(base_rect, 50, 50, 60, 60)
    testing.expect_value(t, excess_padded.width, 0)
    testing.expect_value(t, excess_padded.height, 0)
}

@(test)
test_rect_pad_simple :: proc(t: ^testing.T) {
    base_rect := rl.Rectangle{10, 10, 100, 80}

    padded := rect_pad_simple(base_rect, 10, 20)
    testing.expect_value(t, padded.x, 30)
    testing.expect_value(t, padded.y, 20)
    testing.expect_value(t, padded.width, 60)
    testing.expect_value(t, padded.height, 60)
}