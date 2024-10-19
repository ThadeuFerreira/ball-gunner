package game

import "core:math"
import rl "vendor:raylib"


Tile :: struct {
    id: i32,
    color: rl.Color,
    blocked: bool,
    size : rl.Vector2,
    position : rl.Vector2,
}

TILE_NUM : i32 = 17

// A Chunk as a part of the TileMap that is visible on the screen
Chunk :: struct {
    tiles: []Tile
}

Openings :: struct {
    north: bool,
    east: bool,
    south: bool,
    west: bool,
}

TileMap :: struct {
    chunks: []Chunk
}

make_tile :: proc(position : rl.Vector2, size : rl.Vector2, id: i32, blocked: bool) -> Tile
{
    t := Tile{}
    t.id = id
    t.blocked = blocked
    t.position = position
    t.size = size
    if blocked {
        t.color = rl.GREEN
    } else {
        t.color = rl.BLACK
    }

    return t
}

make_chunk :: proc(tile_size : rl.Vector2, chunk_id : i32, openings : Openings) -> Chunk
{
    c := Chunk{}
    c.tiles = make([]Tile, TILE_NUM*TILE_NUM)
    for i in 0..<TILE_NUM {
        for j in 0..<TILE_NUM {
            tile_id := chunk_id*256 + i32(i)*TILE_NUM + i32(j)
            if i == 0 || j == 0 || i == TILE_NUM -1 || j == TILE_NUM -1{
                blocked := true
                if openings.north && i == i32(TILE_NUM/2) && j == 0 {
                    blocked = false
                }
                if openings.east && i == TILE_NUM -1 && j == i32(TILE_NUM/2)  {
                    blocked = false
                }
                if openings.south && i == i32(TILE_NUM/2)  && j == TILE_NUM -1 {
                    blocked = false
                }
                if openings.west && i == 0 && j == i32(TILE_NUM/2)  {
                    blocked = false
                }
                c.tiles[i*TILE_NUM + j] = make_tile(rl.Vector2{f32(i)*tile_size.x, f32(j)*tile_size.y}, tile_size, tile_id, blocked)
            } else {
                c.tiles[i*TILE_NUM + j] = make_tile(rl.Vector2{f32(i)*tile_size.x, f32(j)*tile_size.y}, tile_size, tile_id, false)
            }
        }
    }
    return c
}

make_tilemap :: proc() -> ^TileMap
{
    tm := new(TileMap)
    tm.chunks = make([]Chunk, 1)
    openings := Openings{true, true, true, true}
    tm.chunks[0] = make_chunk(rl.Vector2{64, 64}, 0, openings)
    return tm
}

draw_tile :: proc(tile : Tile)
{
    rl.DrawRectangle(i32(tile.position.x), i32(tile.position.y), i32(tile.size.x), i32(tile.size.y), tile.color)
}

draw_chunk :: proc(chunk : Chunk)
{
    for i in 0..<TILE_NUM {
        for j in 0..<TILE_NUM {
            draw_tile(chunk.tiles[i*TILE_NUM + j])
        }
    }
}