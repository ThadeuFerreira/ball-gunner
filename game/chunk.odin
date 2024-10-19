package game

/*
This file defines the Chunks.
Chunks are 16x16 grids of tiles.
Each Chunk can have at least 1 opening to the next Chunk and most 4 openings.
When generating a new Chunk, the generator will choose a random number of openings between 1 and 4.
The generator will then choose a random direction for each opening.
The next Chunks will be generated in the direction of the opening.
Chunks will be represented by a double connected graph.
*/

import rl "vendor:raylib"

