package game
import rl "vendor:raylib"
import "core:math"
import "core:math/linalg"

Barrel :: struct {
    color: rl.Color,
    thickness: i32,
    size : i32,
}

BulletStatus :: enum {
    BULLET_ACTIVE,
    BULLET_INACTIVE,
}

Bullet :: struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    color: rl.Color,
    radius: f32,
    status: BulletStatus,
}

Gunner :: struct {
    position: rl.Vector2,
    size: i32,
    color: rl.Color,
    rotation: f32,
    velocity: rl.Vector2,
    acceleration: rl.Vector2,
    ammo: i32,

    barrel : Barrel,
    bullets : [dynamic]^Bullet,
}
MAX_AMMO : i32 = 1000
START_AMMO : i32 = 10
make_gunner :: proc(position: rl.Vector2, size: i32, color: rl.Color) -> ^Gunner
{
    g := new(Gunner)
    b := Barrel{}
    b.color = rl.BLUE
    b.thickness = 5
    b.size = size + 2

    bullets := make([dynamic]^Bullet,0, 100)

    g.position = position
    g.size = size
    g.color = color
    g.rotation = 0
    g.barrel = b
    g.bullets = bullets
    g.ammo = START_AMMO

    return g
}


InputState :: struct {
    rotation: f32,
    acceleration: rl.Vector2,
    shooting: bool,
}

MAX_SPEED : f32 = 20.0
update_gunner :: proc(gunner: ^Gunner, chunk : Chunk)
{
    delta_time := rl.GetFrameTime()
    speed : f32 = 15
    state := get_gunner_state(gunner)
    get_player_input(&state)

    
    // Apply acceleration
    gunner.velocity += state.acceleration

    // Limit speed 
    if rl.Vector2Length(gunner.velocity) > MAX_SPEED {
        gunner.velocity = rl.Vector2Normalize(gunner.velocity)*MAX_SPEED
    }
    
    // Apply drag (optional, for more realistic movement)
    gunner.velocity *= 0.995

    
    // Update position
    gunner.position += gunner.velocity*delta_time*speed

    // Check for collisions
    check, normal := check_gunner_collision(gunner, chunk)
    if check {
        gunner.position -= gunner.velocity*delta_time*speed
        //calculate new velocity of the bounce contrary to the current velocity
        incoming_velocity := rl.Vector2Normalize(gunner.velocity)
        bounce_velocity := linalg.reflect(incoming_velocity, normal)
        gunner.velocity = bounce_velocity*speed
        
    }

    gunner.rotation = state.rotation

    if state.shooting{
        if gunner.ammo > 0 {
            gunner.ammo -= 1
            bullet := new(Bullet)
            bullet.position = rl.Vector2{gunner.position.x + math.sin(gunner.rotation*math.PI/180)*f32(gunner.size), gunner.position.y - math.cos(gunner.rotation*math.PI/180)*f32(gunner.size)}
            bullet.velocity = angle_to_vector(gunner.rotation)*speed*50
            bullet.color = rl.YELLOW
            bullet.radius = 5
            bullet.status = BulletStatus.BULLET_ACTIVE
            append(&gunner.bullets, bullet)
        }
    }

    for i in 0..<len(gunner.bullets) {
        bullet := gunner.bullets[i]
        if bullet.status == BulletStatus.BULLET_INACTIVE {
            continue
        }
        bullet.position += bullet.velocity*delta_time
        check, _ := check_bullet_collision(bullet, chunk)
        if  check {
            bullet.status = BulletStatus.BULLET_INACTIVE
            gunner.bullets[i] = bullet
            continue
        }
    }
}

check_bullet_collision :: proc(bullet : ^Bullet, chunk : Chunk) -> (check : bool, normal : rl.Vector2)
{
    for b in chunk.tiles{
        if !b.blocked {
            continue
        }
        if rl.CheckCollisionCircleRec(bullet.position, bullet.radius, rl.Rectangle{b.position.x, b.position.y, b.size.x, b.size.y}) {
            normal := rl.Vector2{0, 0}
            if bullet.position.x < b.position.x {
                normal.x = -1
            } else if bullet.position.x > b.position.x + b.size.x {
                normal.x = 1
            }
            if bullet.position.y < b.position.y {
                normal.y = -1
            } else if bullet.position.y > b.position.y + b.size.y {
                normal.y = 1
            }
            return true, normal
        }
    }
    return false, rl.Vector2{0, 0}
}

check_gunner_collision :: proc(gunner: ^Gunner, chunk : Chunk) -> (check : bool, normal : rl.Vector2)
{
 
    for i in 0..<len(chunk.tiles) {
        tile := chunk.tiles[i]
        if tile.blocked && rl.CheckCollisionCircleRec(gunner.position, f32(gunner.size), rl.Rectangle{tile.position.x, tile.position.y, tile.size.x, tile.size.y}) {
            normal := rl.Vector2{0, 0}
            if gunner.position.x < tile.position.x {
                normal.x = -1
            } else if gunner.position.x > tile.position.x + tile.size.x {
                normal.x = 1
            }
            if gunner.position.y < tile.position.y {
                normal.y = -1
            } else if gunner.position.y > tile.position.y + tile.size.y {
                normal.y = 1
            }
            return true, normal
        }
    }
    return false, rl.Vector2{0, 0}
}

get_gunner_state :: proc(gunner: ^Gunner) -> InputState
{
    state := InputState{}
    state.rotation = gunner.rotation
    state.acceleration = gunner.acceleration
    
    return state
}

angle_to_vector :: proc(angle : f32) -> rl.Vector2 {
    radians := angle*math.PI/180
    return rl.Vector2{math.sin(radians), -math.cos(radians)}
}

get_player_input :: proc(state : ^InputState)  
{
    if (rl.IsKeyDown(rl.KeyboardKey.W) || rl.IsKeyDown(rl.KeyboardKey.UP)) && !rl.IsKeyDown(rl.KeyboardKey.LEFT_CONTROL) && !rl.IsKeyDown(rl.KeyboardKey.RIGHT_CONTROL) {
        // Calculate acceleration based on ship's current rotation
        acceleration_magnitude : f32 = 0.6
        state.acceleration = angle_to_vector(state.rotation)* acceleration_magnitude
        
    } else if rl.IsKeyDown(rl.KeyboardKey.LEFT_CONTROL) || rl.IsKeyDown(rl.KeyboardKey.RIGHT_CONTROL) {
        state.acceleration = rl.Vector2{0, 0}
    } else {
        state.acceleration = rl.Vector2{0, 0}
    }

    if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
        state.shooting = true
    } else {
        state.shooting = false
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
    rl.DrawCircle(i32(gunner.position.x), i32(gunner.position.y), f32(gunner.size), gunner.color)
    barrel := gunner.barrel
    line_start := rl.Vector2{gunner.position.x, gunner.position.y}
    line_end := rl.Vector2{gunner.position.x + math.sin(gunner.rotation*math.PI/180)*f32(barrel.size), gunner.position.y - math.cos(gunner.rotation*math.PI/180)*f32(barrel.size)}
    rl.DrawLineEx(line_start, line_end, f32(barrel.thickness), barrel.color)

    for i in 0..<len(gunner.bullets) {
        bullet := gunner.bullets[i]
        if bullet.status == BulletStatus.BULLET_INACTIVE {
            continue
        }
        rl.DrawCircleV(bullet.position, bullet.radius, bullet.color)
    }
}

