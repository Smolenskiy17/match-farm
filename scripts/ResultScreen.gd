extends Node2D

@onready var score_label: Label = $ScoreLabel
@onready var coins_label: Label = $CoinsLabel

var final_score: int = 0

func _ready() -> void:
	pass

func setup(p_score: int) -> void:
	final_score = p_score
	@warning_ignore("integer_division")
	var coins_earned := p_score / 10  # 10 очков = 1 монета
	score_label.text = "Очки: " + str(p_score)
	coins_label.text = "Монеты: +" + str(coins_earned)
	GameData.add_coins(coins_earned)
	if p_score > GameData.best_score:
		GameData.best_score = p_score
	GameData.save_game()

func _on_claim_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/FarmScreen.tscn")
