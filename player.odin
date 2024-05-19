package main

import rl "vendor:raylib"

Player :: struct {
	pos:   rl.Vector2,
	speed: f32,
	state: PlayerState,
	size:  int,
}

PlayerState :: union #no_nil {
	Idle,
	Running,
}

Idle :: enum {
	IDLE,
}
Running :: enum {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}
