package maps

import "core:bytes"
import "core:os"
import "core:slice"
import rl "vendor:raylib"

Map :: struct {
	data:    [][]Tile,
	texture: rl.Texture2D,
	rules:   map[Tile]TileInfo,
}

Tile :: enum {
	WATER,
	GRASS,
}

TileInfo :: struct {
	texture: rl.Texture2D,
	rect:    rl.Rectangle,
}

Error :: enum {}

newMap :: proc(bitmapPath: string, rules: map[Tile]TileInfo) -> Map {
	m := loadMap(bitmapPath)
	m.rules = rules

	return m
}

loadMap :: proc(path: string) -> Map {
	data := os.read_entire_file(path) or_else panic("can't load map")
	defer delete(data)

	return bakeMap(data)
}

bakeMap :: proc(data: []byte) -> Map {
	data2D := bytes.split(data, []byte{'\n'})
	defer delete(data2D)

	tileMap := make([][]Tile, len(data2D))
	for row, ri in data2D {
		tileRow := make([]Tile, len(row))
		for b, i in row {
			switch b {
			case '0':
				tileRow[i] = Tile.GRASS
			case:
				tileRow[i] = Tile.WATER
			}
		}
		tileMap[ri] = tileRow
	}

	return Map{data = tileMap}
}

drawMap :: proc(m: Map, tileSize: int) {
	for row, y in m.data {
		for tile, x in row {
			rl.DrawTexturePro(
				m.rules[tile].texture,
				m.rules[tile].rect,
				{f32(x * tileSize), f32(y * tileSize), f32(tileSize), f32(tileSize)},
				{},
				0,
				rl.WHITE,
			)
		}
	}
}
