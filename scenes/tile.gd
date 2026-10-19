extends Node2D
class_name Tile

var type: int = 0
var grid_pos: Vector2i = Vector2i.ZERO

@onready var sprite: Sprite2D = $Sprite

const COLORS = [
	Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.PURPLE
]

func setup(p_type: int, p_grid_pos: Vector2i) -> void:
	type = p_type
	grid_pos = p_grid_pos
	sprite.modulate = COLORS[type]
	if sprite.texture == null:
		var img := Image.create(90, 90, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		sprite.texture = ImageTexture.create_from_image(img)
