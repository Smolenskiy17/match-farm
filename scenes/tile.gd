extends Node2D
class_name Tile

var type: int = 0
var grid_pos: Vector2i = Vector2i.ZERO

@onready var sprite: Sprite2D = $Sprite

const TEXTURES = [
	preload("res://assets/tiles/tile_0.png"),
	preload("res://assets/tiles/tile_1.png"),
	preload("res://assets/tiles/tile_5.png"),
	preload("res://assets/tiles/tile_3.png"),
	preload("res://assets/tiles/tile_6.png"),
	preload("res://assets/tiles/tile_7.png"),
	preload("res://assets/tiles/tile_8.png"),
]

func setup(p_type: int, p_grid_pos: Vector2i) -> void:
	type = p_type
	grid_pos = p_grid_pos
	sprite.texture = TEXTURES[type]
	sprite.modulate = Color.WHITE  # убираем цветной оттенок
