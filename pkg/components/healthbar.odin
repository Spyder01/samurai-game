package components

import "vendor:raylib"

healthbar :: proc (health: ^f32, bounds: raylib.Rectangle) {
	  raylib.GuiProgressBar(bounds, "Health", "", health, 0, 100)
}

