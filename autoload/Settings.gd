extends Node

signal language_changed(lang: String)
signal music_volume_changed(value: float)
signal sfx_volume_changed(value: float)

var language: String = "ru"  # "ru" или "en"
var music_volume: float = 0.7  # 0.0 — 1.0
var sfx_volume: float = 1.0

# Переводы (пока вручную, без .csv)
var translations := {
	"ru": {
		"title": "Match Farm",
		"subtitle": "Выращивай и играй!",
		"play": "Играть",
		"settings": "Настройки",
		"reset": "Сброс",
		"back": "Назад",
		"language": "Язык",
		"music": "Музыка",
		"sfx": "Звуки",
		"coins": "Монеты",
		"build_hint": "Тапни по клетке, чтобы построить",
		"play_match3": "Играть в Match-3",
		"game_over": "Игра окончена!",
		"score": "Очки",
		"claim": "Забрать",
		"not_enough_coins": "Не хватает монет!",
		"built": "Построено",
		"house": "Домик",
		"tree": "Дерево",
	},
	"en": {
		"title": "Match Farm",
		"subtitle": "Grow and play!",
		"play": "Play",
		"settings": "Settings",
		"reset": "Reset",
		"back": "Back",
		"language": "Language",
		"music": "Music",
		"sfx": "Sound",
		"coins": "Coins",
		"build_hint": "Tap a tile to build",
		"play_match3": "Play Match-3",
		"game_over": "Game Over!",
		"score": "Score",
		"claim": "Claim",
		"not_enough_coins": "Not enough coins!",
		"built": "Built",
		"house": "House",
		"tree": "Tree",
	},
}

func tr_game(key: String) -> String:
	if translations.has(language) and translations[language].has(key):
		return translations[language][key]
	return key

func set_language(lang: String) -> void:
	if translations.has(lang):
		language = lang
		save_settings()
		language_changed.emit(lang)

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	save_settings()
	music_volume_changed.emit(music_volume)

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	save_settings()
	sfx_volume_changed.emit(sfx_volume)

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("settings", "language", language)
	config.set_value("settings", "music_volume", music_volume)
	config.set_value("settings", "sfx_volume", sfx_volume)
	config.save("user://settings.cfg")

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		language = config.get_value("settings", "language", "ru")
		music_volume = config.get_value("settings", "music_volume", 0.7)
		sfx_volume = config.get_value("settings", "sfx_volume", 1.0)
