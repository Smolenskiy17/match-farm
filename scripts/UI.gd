extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var board: Node2D = $"../Board"

func _process(_delta: float) -> void:
	if board != null:
		score_label.text = "Очки: " + str(board.score)
