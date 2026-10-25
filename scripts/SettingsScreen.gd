extends Node2D

@onready var language_option: OptionButton = $LanguageOption
@onready var music_slider: HSlider = $MusicSlider
@onready var sfx_slider: HSlider = $SfxSlider
@onready var title_label: Label = $TitleLabel
@onready var language_label: Label = $LanguageLabel
@onready var music_label: Label = $MusicLabel
@onready var sfx_label: Label = $SfxLabel
@onready var back_button: Button = $BackButton

func _ready() -> void:
	# Язык
	language_option.selected = 0 if Settings.language == "ru" else 1
	language_option.item_selected.connect(_on_language_selected)

	# Громкость
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)

	# Сигнал кнопки
	back_button.pressed.connect(_on_back_pressed)

	_update_texts()
	Settings.language_changed.connect(func(_l): _update_texts())

func _update_texts() -> void:
	title_label.text = Settings.tr_game("settings")
	language_label.text = Settings.tr_game("language")
	music_label.text = Settings.tr_game("music")
	sfx_label.text = Settings.tr_game("sfx")
	back_button.text = Settings.tr_game("back")

func _on_language_selected(index: int) -> void:
	Settings.set_language("ru" if index == 0 else "en")

func _on_music_changed(value: float) -> void:
	Settings.set_music_volume(value)

func _on_sfx_changed(value: float) -> void:
	Settings.set_sfx_volume(value)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")
