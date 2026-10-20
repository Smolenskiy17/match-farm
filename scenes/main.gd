extends Node2D

@onready var board: Node2D = $Board

func _ready() -> void:
	board.game_finished.connect(_on_game_finished)

func _on_game_finished(final_score: int) -> void:
	var result_scene = preload("res://scenes/ResultScreen.tscn").instantiate()
	add_child(result_scene)
	result_scene.setup(final_score)
