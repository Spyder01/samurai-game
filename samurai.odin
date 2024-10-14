package samurai

import "core:math/rand"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "vendor:raylib"
import "./pkg/animation"
import "./pkg/physics"
import "./pkg/components"
import "./pkg/vectors"

SCREEN_WIDTH :: 1200
SCREEN_HEIGHT :: 600
SCALE :: 5

getCurrentTexture :: proc (character: animation.CHARACTER_FRAMES, animate: ^animation.Animate) -> raylib.Texture2D {
	  return character[animate.state][animation.getCurrentFrame(animate)]
}

getScoreText :: proc(score: i32) -> cstring {
	buf := [5]u8{}
	str := strconv.itoa(buf[:], cast(int)score)
	strArr := [?]string{
		"Score: ",
		str
	}
	scoreText := strings.concatenate(strArr[:])

	cstr, err := strings.clone_to_cstring(scoreText)
	return cstr
}

setupBackground :: proc(env: ^GameEnvironment, tile: raylib.Texture2D, tileCount: i32, cloud: raylib.Texture2D, cloudPositions: []physics.Vector, rock: raylib.Texture2D) {
	
	raylib.DrawText(getScoreText(env.score), 20, 50, 15, raylib.BLUE)
	raylib.DrawTexture(rock, cast(i32)env.rect.width/3, cast(i32)(env.physics.groundHeight - rock.height/2), raylib.WHITE)

	init := cast(i32)0
	for i := cast(i32)0; i<tileCount; i += 1 {
		raylib.DrawTexture(tile, cast(i32)init, cast(i32)(env.physics.groundHeight + tile.height), raylib.WHITE)  
		init += tile.width
	}

	for position in cloudPositions {
		 raylib.DrawTexture(cloud, position.x, position.y, raylib.WHITE) 
	}

}

CoinContainer :: struct {
	total: u32,
	count: u32,
	distance: f32,
	atomicPoint: f32,
}

spawnCoinContainer :: proc (env: ^GameEnvironment, total: u32, count: u32, offset: f32) -> (container: CoinContainer) {
	container.total = total
	container.count = count
	container.distance = cast(f32)((env.rect.width - offset)/cast(f32)count)
	container.atomicPoint = cast(f32)(total/count)

	return
}

main :: proc () {
	  raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Samurai Game")

		env := &physics.Environment{
			SCREEN_HEIGHT*9/11,
			0.95,
			90,
		}

		gameEnv := &GameEnvironment{
			physics=env,
			rect=raylib.Rectangle{
				0,
				0,
				SCREEN_WIDTH,
				SCREEN_HEIGHT,
			},
			score=0,
		}

		tile := raylib.LoadTexture("assets/tile.png")
		tileCount := cast(i32)(cast(i32)gameEnv.rect.width/tile.width + 1)

		cloud := raylib.LoadTexture("assets/cloud.png")
		clouds: [5]physics.Vector

		for i := 0; i<5; i += 1 {
			x := cast(i32)(rand.uint32()%cast(u32)gameEnv.rect.width)
			if x < 0 {
				x *= -1  
			}

			y := cast(i32)(rand.uint32()%cast(u32)gameEnv.rect.height/2)
			if y < 0 {
				y *= -1  
			}

			clouds[i] = physics.Vector{x,y}
	}

		rock := raylib.LoadTexture("assets/rock.png")
		defer unloadTexture([]raylib.Texture2D{
			rock  
		})

		samuraiRunningFrames := []raylib.Texture2D{
			raylib.LoadTexture("assets/samurai-run-4.png"),  
			raylib.LoadTexture("assets/samurai-run-5.png"),  
			raylib.LoadTexture("assets/samurai-run-6.png"),  
			raylib.LoadTexture("assets/samurai-run-7.png"),  
		}
		defer unloadTexture(samuraiRunningFrames)

		
		samuraiIdleFrames := []raylib.Texture2D{
			raylib.LoadTexture("assets/samurai-idle-1.png"),  
			raylib.LoadTexture("assets/samurai-idle-2.png"),  
			raylib.LoadTexture("assets/samurai-idle-3.png"),  
			raylib.LoadTexture("assets/samurai-idle-4.png"),  
			raylib.LoadTexture("assets/samurai-idle-5.png"),  
		}
		defer unloadTexture(samuraiIdleFrames)

		samuraiAttackFrames := []raylib.Texture2D{
			raylib.LoadTexture("assets/samurai-attack-1.png"),  
			raylib.LoadTexture("assets/samurai-attack-2.png"),  
			raylib.LoadTexture("assets/samurai-attack-3.png"),  
			raylib.LoadTexture("assets/samurai-attack-4.png"),  
			raylib.LoadTexture("assets/samurai-attack-5.png"),  
		}
		defer unloadTexture(samuraiAttackFrames)

		samuraiFrames := animation.CHARACTER_FRAMES{
			animation.CHARACTER_STATE.RUN=samuraiRunningFrames,
			animation.CHARACTER_STATE.IDLE=samuraiIdleFrames,
			animation.CHARACTER_STATE.ATTACK=samuraiAttackFrames,
		}


		samuraiPhysics := &physics.Character{
			position=&physics.Vector{
				x=SCREEN_WIDTH/10, 
				y=env.groundHeight,
			},
			velocity=&physics.Vector{
				x=0,
				y=0,
			},
			verticalAcceleration=10,
			horizontalAcceleration=4,
			height=samuraiIdleFrames[0].height,		
			width=samuraiIdleFrames[0].width,
		}
		
		samuraiAnimate := &animation.Animate{
			animation.CHARACTER_STATE.IDLE,
			0.12,
			0.0,
			map[animation.CHARACTER_STATE]int{
				animation.CHARACTER_STATE.IDLE=0,
				animation.CHARACTER_STATE.RUN=0,
				animation.CHARACTER_STATE.ATTACK=0,
			},
			1.5,
		}
		
		samurai := spawnNewGameObject(samuraiPhysics, samuraiAnimate, getCurrentTexture(samuraiFrames, samuraiAnimate))


		goblinFrames := animation.CHARACTER_FRAMES{
			animation.CHARACTER_STATE.RUN=[]raylib.Texture2D{
				raylib.LoadTexture("assets/goblin-run-1.png"),  
				raylib.LoadTexture("assets/goblin-run-2.png"),  
				raylib.LoadTexture("assets/goblin-run-3.png"),  
				raylib.LoadTexture("assets/goblin-run-4.png"),  
				raylib.LoadTexture("assets/goblin-run-5.png"),  
			},
			animation.CHARACTER_STATE.ATTACK=[]raylib.Texture2D{
				raylib.LoadTexture("assets/goblin-attack-1.png"),  
				raylib.LoadTexture("assets/goblin-attack-2.png"),  
				raylib.LoadTexture("assets/goblin-attack-3.png"),  
				raylib.LoadTexture("assets/goblin-attack-4.png"),  
				raylib.LoadTexture("assets/goblin-attack-5.png"),  
				raylib.LoadTexture("assets/goblin-attack-6.png"),  
				raylib.LoadTexture("assets/goblin-attack-7.png"),  
				raylib.LoadTexture("assets/goblin-attack-8.png"),  
			},
			animation.CHARACTER_STATE.DEATH=[]raylib.Texture2D{
				raylib.LoadTexture("assets/goblin-death-1.png"),  
				raylib.LoadTexture("assets/goblin-death-2.png"),  
				raylib.LoadTexture("assets/goblin-death-3.png"),  
				raylib.LoadTexture("assets/goblin-death-4.png"),  
			},
			animation.CHARACTER_STATE.HIT=[]raylib.Texture2D{
				raylib.LoadTexture("assets/goblin-hit-1.png"),  
				raylib.LoadTexture("assets/goblin-hit-2.png"),  
				raylib.LoadTexture("assets/goblin-hit-3.png"),  
				raylib.LoadTexture("assets/goblin-hit-4.png"),  
				raylib.LoadTexture("assets/goblin-hit-5.png"),  
			}
		}

		defer {
			for key in goblinFrames {
				unloadTexture(goblinFrames[key])  
			}
		}

		goblinPhysics := &physics.Character{
			position=&physics.Vector{
				x=cast(i32)gameEnv.rect.width, 
				y=env.groundHeight,
			},
			velocity=&physics.Vector{
				x=5,
				y=0,
			},
			verticalAcceleration=10,
			horizontalAcceleration=2,
			height=goblinFrames[animation.CHARACTER_STATE.RUN][0].height,		
			width=goblinFrames[animation.CHARACTER_STATE.RUN][0].width,
		}
		
		goblinAnimate := &animation.Animate{
			animation.CHARACTER_STATE.RUN,
			0.12,
			0.0,
			map[animation.CHARACTER_STATE]int{
				animation.CHARACTER_STATE.DEATH=0,
				animation.CHARACTER_STATE.HIT=0,
				animation.CHARACTER_STATE.RUN=0,
				animation.CHARACTER_STATE.ATTACK=0,
			},
			1.5,
		}
	defer {
		for key in goblinFrames {
			unloadTexture(goblinFrames[key])
		}
	}
		
		goblin := spawnNewGameObject(goblinPhysics, goblinAnimate, getCurrentTexture(goblinFrames, goblinAnimate))
		goblin.direction = -1


		coinAnimate := &animation.Animate{
			animation.CHARACTER_STATE.IDLE,
			0.12, 
			0.0,
			map[animation.CHARACTER_STATE]int {
				animation.CHARACTER_STATE.IDLE=0,  
			},
			0.2,
		}
		
		coinsTexture := []raylib.Texture2D{
			raylib.LoadTexture("assets/coin-1.png"),  
			raylib.LoadTexture("assets/coin-2.png"), 
			raylib.LoadTexture("assets/coin-3.png"), 
			raylib.LoadTexture("assets/coin-4.png"), 
		}
		defer unloadTexture(coinsTexture)

		coinFrames := animation.CHARACTER_FRAMES{
			animation.CHARACTER_STATE.IDLE=coinsTexture
		}

		coinPhysics := &physics.Character{
			position=&physics.Vector{
				x=SCREEN_WIDTH/2, 
				y=env.groundHeight,
			},
			velocity=&physics.Vector{
				x=0,
				y=0,
			},
			verticalAcceleration=10,
			horizontalAcceleration=4,
			height=coinsTexture[0].height,		
			width=coinsTexture[0].width,
		}
		
		offset := cast(f32)(samurai.rect.x + 20)
		coinContainer := spawnCoinContainer(gameEnv, 50, 5, offset)

		coins: [dynamic]GameObject
		for i := cast(u32)0; i < coinContainer.count; i += 1 {
			x := cast(i32)i*cast(i32)coinContainer.distance
			if x < 0 {
				x *= -1  
			}
			x += cast(i32)offset
			coinPhysics := &physics.Character{
				position=&physics.Vector{
					x=x,
					y=env.groundHeight,
				},
				velocity=&physics.Vector{
					x=0,
					y=0,
				},
				verticalAcceleration=10,
				horizontalAcceleration=4,
				height=coinsTexture[0].height,		
				width=coinsTexture[0].width,
			}
			
			object := spawnNewGameObject(coinPhysics, coinAnimate, getCurrentTexture(coinFrames, coinAnimate))
			append_elem(&coins, object)
		}

		raylib.SetTargetFPS(gameEnv.physics.FPS)

		for !raylib.WindowShouldClose() {
			if samurai.health <= 0 {
				samurai.visible = false  
			}

			deltaTime := raylib.GetFrameTime()

			animation.animateCharacter(samuraiFrames, samurai.animate, deltaTime)
			animation.animateCharacter(coinFrames, coins[0].animate, deltaTime)
			animation.animateCharacter(goblinFrames, goblin.animate, deltaTime)
			
			samuraiBrain(&samurai, gameEnv, deltaTime)
			goblinBrain(&goblin, &samurai, gameEnv, len(goblinFrames[goblin.animate.state]), deltaTime)
				
			for &coin in coins {
				if coin.visible && raylib.CheckCollisionRecs(samurai.rect, coin.rect) {
					coin.visible = false  
					gameEnv.score += cast(i32)coinContainer.atomicPoint
				}
			}

			raylib.BeginDrawing()

			raylib.ClearBackground(raylib.BLACK)

			setupBackground(gameEnv, tile, tileCount, cloud, []physics.Vector{}, rock)
			components.healthbar(&samurai.health, raylib.Rectangle{40, 10, 200, 25})
			
			coinTexture := getCurrentTexture(coinFrames, coinAnimate)
			for &coin in coins {
				if coin.visible {
					updateTexture(&coin, coinTexture)
					raylib.DrawTexturePro(coin.texture, coin.originRect, coin.rect, [2]f32{0, 0}, 0.0, raylib.WHITE) 
				}
			}
			
			if goblin.visible {
				updateTexture(&goblin, getCurrentTexture(goblinFrames, goblinAnimate))
				raylib.DrawTexturePro(goblin.texture, goblin.originRect, goblin.rect, [2]f32{0, 0}, 0.0, raylib.WHITE)
			}
			
			if samurai.visible {
				updateTexture(&samurai, getCurrentTexture(samuraiFrames, samuraiAnimate))
				raylib.DrawTexturePro(samurai.texture, samurai.originRect, samurai.rect, [2]f32{0, 0}, 0.0, raylib.WHITE) 
			} else {
				raylib.DrawText("GAME OVER", cast(i32)gameEnv.rect.width/2 - 300, cast(i32)gameEnv.rect.height/2 - 20, 80, raylib.BLUE)  
			}
			
			raylib.EndDrawing()
		}

		raylib.CloseWindow()
}

samuraiBrain :: proc(samurai: ^GameObject, gameEnv: ^GameEnvironment, deltaTime: f32) {

			physics.freeFall(samurai.physics, gameEnv.physics, deltaTime)
			updatePosition(samurai, samurai.physics.position)

			if raylib.IsKeyPressed(raylib.KeyboardKey.UP) && samurai.physics.position.y == gameEnv.physics.groundHeight  {
				physics.jump(samurai.physics, gameEnv.physics, deltaTime)	  
				updatePosition(samurai, samurai.physics.position)
			}

			if raylib.IsKeyPressed(raylib.KeyboardKey.LEFT) {
				samurai.direction = -1
			} 

			if raylib.IsKeyPressed(raylib.KeyboardKey.RIGHT) {
				samurai.direction = 1  
			}

			if raylib.IsKeyDown(raylib.KeyboardKey.SPACE) {
				animation.setState(samurai.animate, animation.CHARACTER_STATE.ATTACK)
				updatePosition(samurai, samurai.physics.position)
			} else if raylib.IsKeyDown(raylib.KeyboardKey.RIGHT) || raylib.IsKeyDown(raylib.KeyboardKey.LEFT) {
				animation.setState(samurai.animate, animation.CHARACTER_STATE.RUN)  
				physics.run(samurai.physics, gameEnv.physics, deltaTime, cast(i32)samurai.direction)
				updatePosition(samurai, samurai.physics.position)
			} 
			else {
				animation.setState(samurai.animate, animation.CHARACTER_STATE.IDLE)
				physics.stopRunning(samurai.physics)
				updatePosition(samurai, samurai.physics.position)
			}

			if cast(f32)samurai.physics.position.x >= gameEnv.rect.width {
				updatePosition(samurai, &physics.Vector{
					cast(i32)gameEnv.rect.width,
					samurai.physics.position.y,
				})
			}

			if samurai.physics.position.x < cast(i32)gameEnv.rect.x {
				updatePosition(samurai, &physics.Vector{
					cast(i32)gameEnv.rect.x,
					samurai.physics.position.y,
				})
			}
}

goblinBrain :: proc(goblin: ^GameObject, samurai: ^GameObject, gameEnv: ^GameEnvironment, size: int, deltaTime: f32) {

 if !goblin.visible {
	  return 
 }

 if goblin.health < 0 {
	  animation.setState(goblin.animate, animation.CHARACTER_STATE.DEATH)
 }


 #partial switch goblin.animate.state {
 case .RUN:
	 if goblin.physics.position.x <= 0 {
	   goblin.direction = 1
	 }

	 if goblin.physics.position.x >= cast(i32)gameEnv.rect.width && goblin.direction == 1 {
		 goblin.direction = -1  
	 }

	 direction := vectors.getRelativeDirection(cast(i32)goblin.rect.x, cast(i32)goblin.direction, cast(i32)samurai.rect.x, cast(i32)samurai.direction)

	 if raylib.CheckCollisionRecs(goblin.rect, samurai.rect) && samurai.visible && (direction == vectors.RelativeDirection.FACING_EACH_OTHER || direction == vectors.RelativeDirection.A_BEHIHD_B)  {
		 if samurai.animate.state == animation.CHARACTER_STATE.ATTACK {
				animation.setState(goblin.animate, animation.CHARACTER_STATE.HIT) 
		 } else {
			   animation.setState(goblin.animate, animation.CHARACTER_STATE.ATTACK) 
		 }
	 }

	 physics.run(goblin.physics, gameEnv.physics, deltaTime, cast(i32)goblin.direction)  
	 updatePosition(goblin, goblin.physics.position)

 case .ATTACK:
	 if raylib.CheckCollisionRecs(goblin.rect, samurai.rect) && samurai.health > 0 {
		 samurai.health -= 1*samurai.animate.speed
	 }

	 if !raylib.CheckCollisionRecs(goblin.rect, samurai.rect) {
		  animation.setState(goblin.animate, animation.CHARACTER_STATE.RUN) 
	 } else if samurai.animate.state == animation.CHARACTER_STATE.ATTACK {
			animation.setState(goblin.animate, animation.CHARACTER_STATE.HIT) 
	 }

 case .HIT:
	 if !raylib.CheckCollisionRecs(goblin.rect, samurai.rect) {
		  animation.setState(goblin.animate, animation.CHARACTER_STATE.RUN) 
			return
	 }
	 goblin.health -= 5*goblin.animate.speed
 case .DEATH:
	 if animation.getCurrentFrame(goblin.animate) == size - 1{
		 goblin.visible = false
	 }
 }
}

