package main

import "base:intrinsics"
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:mem"
import "core:net"
import "maps"
import rl "vendor:raylib"

_screenWidth :: 800
_screenHeight :: 600

_tileSize :: 100

_p := Player {
	pos   = {0, 0},
	speed = 2,
	size  = _tileSize * 2,
}

_globalFrames: int = 0
_animFrames: int = 0

_playerTexture: rl.Texture2D
_playerTextureTileSize := 48
_map: maps.Map
_cam := rl.Camera2D {
	target   = _p.pos,
	offset   = {_screenWidth / 2, _screenHeight / 2},
	zoom     = .3,
	rotation = 0,
}

init :: proc() {
	_playerTexture = rl.LoadTexture("resources/Characters/Basic_Charakter_Spritesheet.png")

	grassTexture := rl.LoadTexture("resources/Tilesets/Grass.png")
	waterTexture := rl.LoadTexture("resources/Tilesets/Water.png")
	_map = maps.newMap(
		"map.data",
		{.GRASS = {grassTexture, {16, 80, 16, 16}}, .WATER = {waterTexture, {0, 0, 16, 16}}},
	)
}

handleSecondaryKeys :: proc() {
	if rl.IsKeyPressed(.EQUAL) {
		_cam.zoom *= 1.2
	}
	if rl.IsKeyPressed(.MINUS) {
		_cam.zoom /= 1.2
	}
	_cam.zoom = rl.Clamp(_cam.zoom, 0.2, 4)
}

update :: proc() {
	// frames
	_globalFrames += 1
	if _globalFrames % 6 == 0 {
		_animFrames += 1
	}

	handleSecondaryKeys()

	p := &_p
	mov := rl.Vector2{}

	if rl.IsKeyDown(.W) {
		mov += {0, -1}
		p.state = Running.UP
	}
	if rl.IsKeyDown(.S) {
		mov += {0, 1}
		p.state = Running.DOWN
	}
	if rl.IsKeyDown(.A) {
		mov += {-1, 0}
		p.state = .UP
		p.state = Running.LEFT
	}
	if rl.IsKeyDown(.D) {
		mov += {1, 0}
		p.state = .UP
		p.state = Running.RIGHT
	}

	if mov == {0, 0} {
		p.state = Idle.IDLE
	}

	mov = rl.Vector2Normalize(mov)
	p.pos += mov * p.speed
}

resolvePlayerTextureRect :: proc(p: Player) -> rl.Rectangle {
	tile := resolvePlayerTextureTile(p)
	tile *= _playerTextureTileSize
	return {f32(tile[0]), f32(tile[1]), f32(_playerTextureTileSize), f32(_playerTextureTileSize)}
}

Tile :: distinct [2]int

resolvePlayerTextureTile :: proc(p: Player) -> Tile {
	frame := _animFrames % 4
	switch t in p.state {
	case Idle:
		return {0, 0}
	case Running:
		switch p.state.(Running) {
		case .DOWN:
			return {frame, 0}
		case .UP:
			return {frame, 1}
		case .LEFT:
			return {frame, 2}
		case .RIGHT:
			return {frame, 3}
		}
	}

	return {}
}

drawPlayer :: proc(p: Player) {
	textureRect := resolvePlayerTextureRect(p)

	rl.DrawTexturePro(
		_playerTexture,
		textureRect,
		{p.pos[0], p.pos[1], f32(p.size), f32(p.size)},
		{f32(p.size) / 2, f32(p.size) / 2},
		0,
		rl.WHITE,
	)
}

drawStats :: proc() {
	rl.DrawFPS(0, 20)

	stats := fmt.caprintf("pos: x = %f, y = %f, state = %v", _p.pos[0], _p.pos[1], _p.state)
	defer delete(stats)
	rl.DrawText(stats, 0, 0, 14, rl.BLACK)
}

render :: proc() {
	rl.BeginDrawing()
	rl.BeginMode2D(_cam)
	rl.ClearBackground(rl.GRAY)

	// World
	maps.drawMap(_map, _tileSize)
	drawPlayer(_p)
	_cam.target = _p.pos

	// UI
	drawStats()

	rl.EndMode2D()
	rl.EndDrawing()
}

main :: proc() {
	rl.InitWindow(_screenWidth, _screenHeight, "gsdg")
	rl.SetTargetFPS(60)

	init()

	for !rl.WindowShouldClose() {
		update()
		render()
	}
}
