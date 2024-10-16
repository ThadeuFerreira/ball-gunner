package gunner
import rl "vendor:raylib"
import "core:math"

Gunner :: struct {
    pos: rl.Vector2,
    size: i32,
    color: rl.Color,
    rotation: f32,
    acceleration: rl.Vector2,
    ammo: i32,
}

make_gunner :: proc(pos: rl.Vector2, size: i32, color: rl.Color) -> ^Gunner
{
    g := new(Gunner)
    g.pos = pos
    g.size = size
    g.color = color
    return g
}


InputState :: struct {
    rotation: f32,
    acceleration: rl.Vector2,
    ammo: i32,
}

update_gunner :: proc(gunner: ^Gunner)
{
    state := get_gunner_state(gunner)
    get_player_input(&state)

    gunner.rotation = state.rotation
    gunner.acceleration = state.acceleration
    gunner.ammo = state.ammo
    gunner.pos = gunner.pos + gunner.acceleration
}

get_gunner_state :: proc(gunner: ^Gunner) -> InputState
{
    state := InputState{}
    state.rotation = gunner.rotation
    state.acceleration = gunner.acceleration
    state.ammo = gunner.ammo
    return state
}

angle_to_vector :: proc(angle : f32) -> rl.Vector2 {
    radians := angle*math.PI/180
    return rl.Vector2{math.sin(radians), -math.cos(radians)}
}

get_player_input :: proc(state : ^InputState)  
{
    if rl.IsKeyDown(rl.KeyboardKey.SPACE) && !rl.IsKeyDown(rl.KeyboardKey.LEFT_CONTROL) && !rl.IsKeyDown(rl.KeyboardKey.RIGHT_CONTROL) {
        // Calculate acceleration based on ship's current rotation
        acceleration_magnitude : f32 = 0.6
        state.acceleration = angle_to_vector(state.rotation)* acceleration_magnitude
        
    } else if rl.IsKeyDown(rl.KeyboardKey.LEFT_CONTROL) || rl.IsKeyDown(rl.KeyboardKey.RIGHT_CONTROL) {
        // fire_bullet(ship)
        state.ammo -= 1
        state.acceleration = rl.Vector2{0, 0}
    } else {
        state.acceleration = rl.Vector2{0, 0}
    }
    
    rotation_speed : f32 = 5
    if rl.IsKeyDown(rl.KeyboardKey.LEFT) || rl.IsKeyDown(rl.KeyboardKey.A) {
        state.rotation -= rotation_speed
    }
    if rl.IsKeyDown(rl.KeyboardKey.RIGHT) || rl.IsKeyDown(rl.KeyboardKey.D) {
        state.rotation += rotation_speed
    }    
}


draw_gunner :: proc(gunner: Gunner)
{
    rl.DrawCircle(i32(gunner.pos.x), i32(gunner.pos.y), f32(gunner.size), gunner.color)
}