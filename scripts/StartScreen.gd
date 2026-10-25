extends Node2D

func _ready() -> void:
	GameData.load_game()
	Settings.load_settings()
	_update_texts()
	Settings.language_changed.connect(func(_l): _update_texts())

func _update_texts() -> void:
	$TitleLabel.text = Settings.tr_game("title")
	$SubtitleLabel.text = Settings.tr_game("subtitle")
	$PlayButton.text = Settings.tr_game("play")
	$ResetButton.text = Settings.tr_game("reset")

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/FarmScreen.tscn")

func _on_reset_button_pressed() -> void:
	GameData.coins = 0
	GameData.wood = 0
	GameData.best_score = 0
	GameData.save_game()
	# Перезапустим экран
	get_tree().reload_current_scene()

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/SettingsScreen.tscn")
