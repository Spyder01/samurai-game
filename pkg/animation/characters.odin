package animation

import "vendor:raylib"

CHARACTER_STATE :: enum {
	  IDLE,
		RUN,
		ATTACK,
		DEATH,
		HIT,
}

CHARACTER_FRAMES :: map[CHARACTER_STATE][]raylib.Texture2D


Animate :: struct {
	state: CHARACTER_STATE,
	speed: f32,
	frameTime: f32,
	currentFrame: map[CHARACTER_STATE]int,
	scale: f32,
}

setState :: proc(animate: ^Animate, state: CHARACTER_STATE) {
	  animate.state = state
}

getCurrentFrame :: proc (animate: ^Animate) -> int {
	  return animate.currentFrame[animate.state]
}

animateCharacter :: proc(frames: CHARACTER_FRAMES, animate: ^Animate, deltaTime: f32) {
	animate.frameTime += deltaTime

	if animate.frameTime >= animate.speed {
		 animate.frameTime = 0.0 
		 animate.currentFrame[animate.state] += 1

		 if animate.currentFrame[animate.state] >= len(frames[animate.state]) {
			 animate.currentFrame[animate.state] = 0  
		 }
	}
}

