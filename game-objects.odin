package samurai

import "vendor:raylib"
import "./pkg/physics"
import "./pkg/animation"

GameEnvironment :: struct {
	physics: ^physics.Environment,
	rect: raylib.Rectangle,
	score: i32,
}

GameObject :: struct {
	texture: raylib.Texture2D,
	physics: ^physics.Character, 
	animate: ^animation.Animate,
	health: f32,
	visible: bool,
	direction: f32,
	rect:  raylib.Rectangle,
	originRect: raylib.Rectangle,
}

spawnNewGameObject :: proc(characterPhysics: ^physics.Character, animate: ^animation.Animate, texture: raylib.Texture2D) -> GameObject {
	 return GameObject{
		 texture,
		 characterPhysics,
		 animate,
		 100,
		 true,
		 1,
		 raylib.Rectangle{
				x=cast(f32)characterPhysics.position.x,
				y=cast(f32)characterPhysics.position.y,
				width=cast(f32)texture.width*animate.scale, 
				height=cast(f32)texture.height*animate.scale,
		 },
		 raylib.Rectangle{
			 x=0,
			 y=0,
			 width=cast(f32)texture.width,
			 height=cast(f32)texture.height
		 }
	 }
}

toggleDirection :: proc(gameObject: ^GameObject) {
	gameObject.direction = -1
}

updatePosition :: proc(gameObject: ^GameObject, position: ^physics.Vector) {
	  gameObject.physics.position = position
		gameObject.rect.x = cast(f32)position.x
		gameObject.rect.y = cast(f32)position.y
}

updateTexture :: proc(gameObject: ^GameObject, texture: raylib.Texture2D) {
		gameObject.texture = texture
	  gameObject.rect.width = cast(f32)texture.width*gameObject.animate.scale
		gameObject.rect.height = cast(f32)texture.height*gameObject.animate.scale
		gameObject.originRect = raylib.Rectangle{
					 x=0,
					 y=0,
					 width=cast(f32)texture.width*gameObject.direction,
					 height=cast(f32)texture.height
				 }
}

resetGameObject :: proc(gameObject: ^GameObject, characterPhysics: ^physics.Character, animate: ^animation.Animate, texture: raylib.Texture2D) {
	 
	gameObject.texture = texture
	gameObject.physics = characterPhysics
	gameObject.animate = animate
	gameObject.visible = true
	gameObject.direction = 1
	gameObject.rect = raylib.Rectangle{
						x=cast(f32)characterPhysics.position.x,
						y=cast(f32)characterPhysics.position.y,
						width=cast(f32)texture.width*animate.scale, 
						height=cast(f32)texture.height*animate.scale,
				 }
	gameObject.originRect = raylib.Rectangle{
			 x=0,
			 y=0,
			 width=cast(f32)texture.width,
			 height=cast(f32)texture.height
		 }
}


unloadTexture :: proc(textures: []raylib.Texture2D) {
	  for texture in textures {
			raylib.UnloadTexture(texture)  
		}
}
