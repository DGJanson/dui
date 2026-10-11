package dui

import "core:fmt"
import "core:strings"
import "core:time"
import rl "vendor:raylib"

when ODIN_BUILD_MODE == .Executable {
    main :: proc() {

        // Standard draw loop
        rl.InitWindow(1280, 720, "DUI DEMO")
        rl.SetTargetFPS(0)
        rl.SetExitKey(rl.KeyboardKey.KEY_NULL)
        defer rl.CloseWindow()

        // Load font
        cf := rl.LoadFontEx("target/caskaydia.ttf", 30, nil, 0)
        defer rl.UnloadFont(cf)

        current_frame := time.now()

        nr_frames := 0
        nr_polls := 0

        for !rl.WindowShouldClose() {
            // Time since loop
            poll_time := time.now()
            should_draw := false
            nr_polls += 1

            if time.diff(current_frame, poll_time) >= 100 * time.Millisecond {
                should_draw = true
                current_frame = poll_time
            }

            // Draw
            if should_draw {
                nr_frames += 1
                rl.BeginDrawing()
                rl.ClearBackground(rl.DARKGRAY)

                text_vec := rl.Vector2{440, 360}
                text := fmt.aprintf("polls: %d \t frames: %d", nr_polls, nr_frames, allocator = context.temp_allocator)
                text_c := strings.clone_to_cstring(text, context.temp_allocator)
                rl.DrawTextEx(cf, text_c, text_vec, 15, 0, rl.WHITE)

                rl.EndDrawing()
                free_all(context.temp_allocator)
            }

            time.sleep(10 * time.Millisecond)
        }
    }
}

