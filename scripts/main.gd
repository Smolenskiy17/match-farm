extends Node

func _ready() -> void:
	# Определяем, какой экран показать:
	# Если пришли из ResultScreen — показываем ферму
	# (по умолчанию — ферма, match-3 запускается отдельно)
	get_tree().change_scene_to_file("res://scenes/FarmScreen.tscn")
