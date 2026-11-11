package dui

import rl "vendor:raylib"

// This struct holds all basic style settings
// Generate it once and pass it around to
// other DUI methods, so you only need to
// define style once
DuiStyle :: struct {
    // font, loaded via raylib
    font:            rl.Font,
    // fontsizes
    fontsize:        f32,
    fontsize_header: f32,
    // extra pixels between lines
    line_spacing:    f32,
    // color scheme
    colors:          DuiColors,
}

// A simple collection of preset colors
DuiColors :: struct {
    // foreground
    fg:     rl.Color,
    fg1:    rl.Color,
    fg2:    rl.Color,
    // backgrounds
    bg:     rl.Color,
    bg1:    rl.Color,
    bg2:    rl.Color,

    // Specifics, based on terminal-ish schemes
    red:    rl.Color,
    yellow: rl.Color,
    green:  rl.Color,
    blue:   rl.Color,
    purple: rl.Color,
    aqua:   rl.Color,
    orange: rl.Color,
}

// Constructor
create_style :: proc(font: rl.Font, fontsize, fontsize_header, line_spacing: f32, colors: DuiColors) -> DuiStyle {
    return DuiStyle{font, fontsize, fontsize_header, line_spacing, colors}
}

// Very simple style thingie that creates style with
// some defaults.
// Mostly for testing!
create_simple_style :: proc() -> DuiStyle {
    return DuiStyle{rl.GetFontDefault(), 16, 18, 0, scheme_everforest()}
}

// some default color schemes
scheme_everforest :: proc() -> DuiColors {
    return DuiColors {
        fg = rl.Color{211, 198, 170, 255},
        fg1 = rl.Color{159, 169, 160, 255},
        fg2 = rl.Color{133, 146, 137, 255},
        bg = rl.Color{52, 63, 68, 255},
        bg1 = rl.Color{61, 72, 77, 255},
        bg2 = rl.Color{71, 82, 88, 255},
        red = rl.Color{230, 126, 128, 255},
        yellow = rl.Color{219, 188, 127, 255},
        green = rl.Color{167, 192, 128, 255},
        blue = rl.Color{127, 187, 179, 255},
        purple = rl.Color{214, 153, 182, 255},
        aqua = rl.Color{131, 192, 146, 255},
        orange = rl.Color{230, 152, 117, 255},
    }
}

