package game

import rl "vendor:raylib"

Flag :: struct {
    position : rl.Vector2,
    start_position : rl.Vector2,
    size : rl.Vector2,
    color : rl.Color,
    sprite : rl.Texture2D,
    state : Flag_State,
    player_id : i32,
}

Flag_State :: enum {
    BASE,
    TAKEN,
    WAITING,
}

make_flag :: proc(position : rl.Vector2, size : rl.Vector2, player_id :i32, color : rl.Color, sprite : rl.Texture2D) -> Flag
{
    f := Flag{}
    f.start_position = position
    f.position = position
    f.size = size
    f.color = color
    f.sprite = sprite
    f.state = Flag_State.BASE
    f.player_id = player_id

    return f
}

draw_flag :: proc(flag : Flag)
{
    rl.DrawTexture(flag.sprite, i32(flag.position.x) - 32, i32(flag.position.y) - 32, flag.color)

    // Draw the base in the start position

    rl.DrawCircleLines(i32(flag.start_position.x), i32(flag.start_position.y), 100, flag.color)
}

