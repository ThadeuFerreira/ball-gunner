package game

import rl "vendor:raylib"


capture_flag :: proc(player : ^Gunner, flag : ^Flag)
{
    if player.player_id == flag.player_id {
        return
    }
    if flag.state == Flag_State.BASE {
        if rl.Vector2Distance(player.position, flag.position) < 20 {
            flag.state = Flag_State.TAKEN
        }
    } else if flag.state == Flag_State.TAKEN {
        flag.position = player.position
        if rl.Vector2Distance(player.position, flag.position) > 20 {
            flag.state = Flag_State.WAITING
        }
    } else if flag.state == Flag_State.WAITING {
        if rl.Vector2Distance(player.position, flag.position) < 20 {
            flag.state = Flag_State.TAKEN
        }
    }
} 

recover_flag :: proc(player : ^Gunner, flag : ^Flag)
{
    if flag.state == Flag_State.WAITING {
        if rl.Vector2Distance(player.position, flag.position) < 20 {
            flag.state = Flag_State.BASE
            flag.position = flag.start_position
        }
    }
}

check_bullet_hit :: proc(player : ^Gunner, enemies : []^Gunner)
{
    for enemy in enemies {
        if player.player_id == enemy.player_id {
            continue
        }
        for bullet in player.bullets {
            if rl.CheckCollisionCircleRec(bullet.position, bullet.radius, rl.Rectangle{enemy.position.x, enemy.position.y, f32(enemy.size), f32(enemy.size)}) {
                enemy.status = GUNNER_STATUS.GUNNER_DEAD
                bullet.status = BulletStatus.BULLET_INACTIVE
            }
        }
    }
}

update_game :: proc(players : []^Gunner, flags : []^Flag, chunks : []Chunk)
{
    for player in players {
        if player.player_id != 1 {
            continue
        }
        update_gunner(player, chunks)
        for flag in flags {
            capture_flag(player, flag)
            recover_flag(player, flag)
        }
        check_bullet_hit(player, players)
    }
}