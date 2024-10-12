package physics

import "core:fmt"

Vector :: struct {
	x: i32,
	y: i32,
}

Character :: struct {
	position: ^Vector,
	velocity: ^Vector,
	verticalAcceleration: f32,
	horizontalAcceleration: f32,
	height: i32,
	width: i32,
}

Environment :: struct {
	groundHeight: i32,
	gravity: f32,
	FPS: i32,
}

freeFall :: proc (character: ^Character, env: ^Environment, deltaTime: f32) {
	 isFalling := !(character.position.y >= env.groundHeight)
	 
	 if  isFalling {

		 deltaV := cast(i32)(env.gravity * deltaTime * cast(f32)env.FPS)
		 if deltaV == 0 {
			 deltaV = 1  
		 }
			character.velocity.y += deltaV			   
			character.position.y += character.velocity.y

			if character.position.y >= env.groundHeight {
			 character.position.y = env.groundHeight  
			 character.velocity.y = 0
	 }
	}
}

jump :: proc (character: ^Character, env: ^Environment, deltaTime: f32) {
		isJumping := !(character.position.y <= (env.groundHeight - 100))
	
	 if isJumping {
		 deltaV := cast(i32)(character.verticalAcceleration * deltaTime * cast(f32)env.FPS)
		 if deltaV == 0 {
			 deltaV = 1  
		 }
		 character.velocity.y -= deltaV
		 character.position.y += character.velocity.y 
		 
		 if character.position.y <= env.groundHeight - 100 {
			 character.position.y = env.groundHeight - 100
			 character.velocity.y = 0
		 }
	 }
}

run :: proc (character: ^Character, env: ^Environment, deltaTime: f32, direction: i32) {
	deltaV := cast(i32)(character.horizontalAcceleration*deltaTime*cast(f32)env.FPS)
	if deltaV == 0 {
		 deltaV = 1 
	}

	character.position.x += deltaV*direction
}

stopRunning :: proc(character: ^Character) {
	  character.velocity.x = 0
}

