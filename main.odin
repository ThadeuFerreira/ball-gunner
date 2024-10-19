package main

import rl "vendor:raylib"
import "core:math"
import "core:mem"
import "core:fmt"
import "core:strings"
import "/game"




screen_width : i32 = 1400
screen_height : i32 = 1400
play_width : f32 = 1000
score_width : f32 = f32(screen_width) - play_width

SHIP_SIZE : i32 = 30

BRUSH_SHAPE :: enum {
    SQUARE,
    CIRCLE
}

main :: proc()
{
    // Initialization
    //--------------------------------------------------------------------------------------

    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    temp_track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&temp_track, context.temp_allocator)
    context.temp_allocator = mem.tracking_allocator(&temp_track)

    defer {
        if len(temp_track.allocation_map) > 0 {
            fmt.eprintf("=== %v allocations not freed: ===\n", len(temp_track.allocation_map))
            for _, entry in temp_track.allocation_map {
                fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
            }
        }
        if len(temp_track.bad_free_array) > 0 {
            fmt.eprintf("=== %v incorrect frees: ===\n", len(temp_track.bad_free_array))
            for entry in temp_track.bad_free_array {
                fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
            }
        }
        mem.tracking_allocator_destroy(&temp_track)

        if len(track.allocation_map) > 0 {
            fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
            for _, entry in track.allocation_map {
                fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
            }
        }
        if len(track.bad_free_array) > 0 {
            fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
            for entry in track.bad_free_array {
                fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
            }
        }
        mem.tracking_allocator_destroy(&track)
    }
    

    rl.SetConfigFlags(rl.ConfigFlags{rl.ConfigFlag.WINDOW_TRANSPARENT});

    rl.InitWindow(screen_width, screen_height, "raylib [core] example - basic window");
    rl.HideCursor()
        

    rl.SetTargetFPS(120) // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    rl.SetTraceLogLevel(rl.TraceLogLevel.ALL) // Show trace log messages (LOG_INFO, LOG_WARNING, LOG_ERROR, LOG_DEBUG)
    showMessageBox := false
    toggle := false
    spawn_timer : f32 = 0.0
    game_over := false

    gunner_position := rl.Vector2{play_width/2, f32(screen_height/2)}
    gunner := game.make_gunner(gunner_position, SHIP_SIZE, rl.RED)
  
    tilemap := game.make_tilemap()
    // Main game loop
    for !rl.WindowShouldClose()    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        
        mouse_pos := rl.GetMousePosition()
        // if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
        //     a := game.Make_asteroid(mouse_pos, 120, 60, rl.RED, 3)
        //     append(&asteroids, a)
        // }
        spawn_timer += rl.GetFrameTime()
        if spawn_timer > 1 {

        }

        st_mouse_pos :=  rl.TextFormat( "%v, %v", mouse_pos.x ,mouse_pos.y)
        rl.DrawText(st_mouse_pos, i32(mouse_pos.x), i32(mouse_pos.y), 20, rl.WHITE)
        game.draw_chunk(tilemap.chunks[0])
        game.update_gunner(gunner)
        game.draw_gunner(gunner^)
        rl.EndDrawing()
        free_all(context.temp_allocator)
    }
    // De-Initialization
    free(gunner)
    
    rl.CloseWindow()
}