package dui

import rl "vendor:raylib"

// This file contains some helper procedures for
// layout options
// We do not seriously check input, eg. if you want to split
// a 1 pixel wide rect you will get nonsense.
// This is fine, we expect input to be checked

// Split a rect horizontally
// Ratio should simply be between 0 and 1.
// The ratio determines the size of the LEFT rect.
// returns left_rect, right_rect
rect_split_horizontally :: proc(rect: rl.Rectangle, ratio: f32) -> (rl.Rectangle, rl.Rectangle) {
    r := clamp(ratio, 0.0, 1.0)
    left_width := rect.width * r
    right_width := rect.width - left_width

    left_rect := rl.Rectangle{rect.x, rect.y, left_width, rect.height}
    right_rect := rl.Rectangle{rect.x + left_width, rect.y, right_width, rect.height}

    return left_rect, right_rect
}

// Split a rect vertically
// Ratio should simply be between 0 and 1.
// The ratio determines the size of the TOP rect.
// returns top_rect, bottom_rect
rect_split_vertically :: proc(rect: rl.Rectangle, ratio: f32) -> (rl.Rectangle, rl.Rectangle) {
    r := clamp(ratio, 0.0, 1.0)
    top_height := rect.height * r
    bottom_height := rect.height - top_height

    top_rect := rl.Rectangle{rect.x, rect.y, rect.width, top_height}
    bottom_rect := rl.Rectangle{rect.x, rect.y + top_height, rect.width, bottom_height}

    return top_rect, bottom_rect
}

// Cuts a left slice of a rect
// cuts based on fixed pixel amount
// returns left rect, rest rect
rect_cut_left :: proc(rect: rl.Rectangle, pixels: f32) -> (left, rest: rl.Rectangle) {
    p := clamp(pixels, 0, rect.width)

    left_rect := rl.Rectangle{rect.x, rect.y, p, rect.height}
    rest_rect := rl.Rectangle{rect.x + p, rect.y, rect.width - p, rect.height}

    return left_rect, rest_rect
}

// Cuts a right slice of a rect
// cuts based on fixed pixel amount
// returns right rect, rest rect
rect_cut_right :: proc(rect: rl.Rectangle, pixels: f32) -> (right, rest: rl.Rectangle) {
    p := clamp(pixels, 0, rect.width)

    right_rect := rl.Rectangle{rect.x + rect.width - p, rect.y, p, rect.height}
    rest_rect := rl.Rectangle{rect.x, rect.y, rect.width - p, rect.height}

    return right_rect, rest_rect
}

// Cuts a top slice of a rect
// cuts based on fixed pixel amount
// returns top rect, rest rect
rect_cut_top :: proc(rect: rl.Rectangle, pixels: f32) -> (top, rest: rl.Rectangle) {
    p := clamp(pixels, 0, rect.height)

    top_rect := rl.Rectangle{rect.x, rect.y, rect.width, p}
    rest_rect := rl.Rectangle{rect.x, rect.y + p, rect.width, rect.height - p}

    return top_rect, rest_rect
}

// Cuts a bottom slice of a rect
// cuts based on fixed pixel amount
// returns bottom rect, rest rect
rect_cut_bottom :: proc(rect: rl.Rectangle, pixels: f32) -> (bottom, rest: rl.Rectangle) {
    p := clamp(pixels, 0, rect.height)

    bottom_rect := rl.Rectangle{rect.x, rect.y + rect.height - p, rect.width, p}
    rest_rect := rl.Rectangle{rect.x, rect.y, rect.width, rect.height - p}

    return bottom_rect, rest_rect
}

// Get a a center box in the passed rectangle.
// Use eg for popups and the like
// Pass a rectangle that holds should hold the new centered rect
// Pass the size of the NEW rectangle
// Note that if the sizes are bigger than the containing rect,
// you will simply get the width and or height of the containing rect
rect_get_center :: proc(rect: rl.Rectangle, size_horizontal: f32, size_vertical: f32) -> rl.Rectangle {
    w := size_horizontal
    if w > rect.width {
        w = rect.width
    }
    if w < 0 {
        w = 0
    }

    h := size_vertical
    if h > rect.height {
        h = rect.height
    }
    if h < 0 {
        h = 0
    }

    x := rect.x + (rect.width - w) / 2
    y := rect.y + (rect.height - h) / 2

    return rl.Rectangle{x, y, w, h}
}

// Get a rect inside the passed rect.
// Use a simple padding, vertical will be used for top and bottom,
// horizontal will be used for left and right
// For more control use rect_pad
// returns the new rect
// Note if the padding is larger than the rect, you will get a 0
// height or width rect!
rect_pad_simple :: proc(rect: rl.Rectangle, vertical_pad: f32, horizontal_pad: f32) -> rl.Rectangle {
    return rect_pad(rect, vertical_pad, vertical_pad, horizontal_pad, horizontal_pad)
}

// Get a rect inside the passed rect.
// Pass padding for top, bottom, left and right
// returns the new rect
// Note if the padding is larger than the rect, you will get a 0
// height or width rect!
rect_pad :: proc(rect: rl.Rectangle, top: f32, bottom: f32, left: f32, right: f32) -> rl.Rectangle {
    w := rect.width - (left + right)
    if w < 0 {
        w = 0
    }

    h := rect.height - (top + bottom)
    if h < 0 {
        h = 0
    }

    x := rect.x + left
    y := rect.y + top

    return rl.Rectangle{x, y, w, h}
}