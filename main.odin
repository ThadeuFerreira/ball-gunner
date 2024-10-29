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
play_height : f32 = 1000
score_width : f32 = f32(screen_width) - play_width

GUNNER_SIZE : i32 = 10

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

    rl.InitWindow(screen_width, screen_height, "MP Game from the early 2000s");
    rl.HideCursor()
        

    rl.SetTargetFPS(120) // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    rl.SetTraceLogLevel(rl.TraceLogLevel.ALL) // Show trace log messages (LOG_INFO, LOG_WARNING, LOG_ERROR, LOG_DEBUG)
    showMessageBox := false
    toggle := false
    spawn_timer : f32 = 0.0
    game_over := false

    gunner_position_red := rl.Vector2{play_width/2, play_height/2}
    gunner_position_blue := rl.Vector2{1500, 1500}
    gunner_red := game.make_gunner(gunner_position_red, 1, rl.RED)
    gunner_blue := game.make_gunner(gunner_position_blue, 2, rl.BLUE)

    camera := rl.Camera2D{};
    camera.target = gunner_red.position;
    camera.offset = rl.Vector2{ play_width/2.0, play_height/2.0 };
    camera.rotation = 0.0;
    camera.zoom = 1.0;

    flag_red := game.make_flag(rl.Vector2{play_width/2 - 100, play_height/2 - 100}, rl.Vector2{20, 20}, 1, rl.RED, rl.LoadTexture("flag.png"))
    flag_blue := game.make_flag(rl.Vector2{1600, 1600}, rl.Vector2{20, 20}, 2, rl.BLUE, rl.LoadTexture("flag.png"))

  
    tilemap := game.make_tilemap()
    players := []^game.Gunner{gunner_red, gunner_blue}
    flags := []^game.Flag{&flag_red, &flag_blue}

    background_color := rl.Color{128,255,170,255}
    // Main game loop
    for !rl.WindowShouldClose()    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        rl.BeginDrawing()
        rl.ClearBackground(background_color)
        
        
        mouse_pos := rl.GetMousePosition()
        global_position := rl.GetScreenToWorld2D(mouse_pos, camera)
        // if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
        //     a := game.Make_asteroid(mouse_pos, 120, 60, rl.RED, 3)
        //     append(&asteroids, a)
        // }
        spawn_timer += rl.GetFrameTime()
        if spawn_timer > 1 {

        }

        camera.target = gunner_red.position
        rl.BeginMode2D(camera)
        game.draw_chunk(tilemap.chunks)
        game.update_game(players, flags, tilemap.chunks)
        game.draw_gunner(gunner_red^)
        game.draw_gunner(gunner_blue^)
        game.draw_flag(flag_red)
        game.draw_flag(flag_blue)

        
        rl.EndMode2D()
        st_mouse_pos :=  rl.TextFormat( "%v, %v", mouse_pos.x ,mouse_pos.y)
        st_global_pos :=  rl.TextFormat( "%v, %v", i32(global_position.x) ,i32(global_position.y))
        rl.DrawText(st_mouse_pos, i32(mouse_pos.x), i32(mouse_pos.y), 20, rl.WHITE)
        rl.DrawText(st_global_pos, i32(mouse_pos.x), i32(mouse_pos.y) + 20, 20, rl.WHITE)
        rl.EndDrawing()
        free_all(context.temp_allocator)
    }
    // De-Initialization
    free(gunner_red)
    
    rl.CloseWindow()
}