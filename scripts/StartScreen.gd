extends Control

func _ready() -> void:
	GameData.load_game()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/FarmScreen.tscn")

func _on_reset_button_pressed() -> void:
	GameData.coins = 0
	GameData.wood = 0
	GameData.best_score = 0
	GameData.save_game()
	# Перезапустим экран
	get_tree().reload_current_scene()
