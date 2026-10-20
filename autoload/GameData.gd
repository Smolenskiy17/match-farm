extends Node

var coins: int = 0
var wood: int = 0
var best_score: int = 0

func add_coins(amount: int) -> void:
	coins += amount

func add_wood(amount: int) -> void:
	wood += amount

func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("resources", "coins", coins)
	config.set_value("resources", "wood", wood)
	config.set_value("stats", "best_score", best_score)
	config.save("user://save.cfg")

func load_game() -> void:
	var config := ConfigFile.new()
	if config.load("user://save.cfg") == OK:
		coins = config.get_value("resources", "coins", 0)
		wood = config.get_value("resources", "wood", 0)
		best_score = config.get_value("stats", "best_score", 0)
