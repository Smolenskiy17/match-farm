extends Node2D

const GRID_SIZE := 4
const TILE_SIZE := 160
const BOARD_OFFSET := Vector2(40, 300)

# Что можно построить: тип → цена в монетах
const BUILDINGS = {
	0: {"name": "Домик", "cost": 10, "color": Color.BROWN},
	1: {"name": "Дерево", "cost": 5, "color": Color.GREEN},
}

var grid: Array = []  # grid[y][x] = Node2D или null

@onready var coins_label: Label = $UI/CoinsLabel
@onready var build_label: Label = $UI/BuildLabel

func _ready() -> void:
	_init_grid()
	_update_ui()

func _init_grid() -> void:
	grid.clear()
	for y in GRID_SIZE:
		var row := []
		row.resize(GRID_SIZE)
		grid.append(row)

func _update_ui() -> void:
	coins_label.text = "Монеты: " + str(GameData.coins)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_click(event.position)

func _on_click(pos: Vector2) -> void:
	var gp := _pixel_to_grid(pos)
	if not _is_valid(gp):
		return
	if grid[gp.y][gp.x] != null:
		return  # уже занято
	# Строим «Домик» по умолчанию
	_try_build(gp, 0)

func _try_build(gp: Vector2i, building_type: int) -> void:
	var info = BUILDINGS[building_type]
	if GameData.coins < info.cost:
		build_label.text = "Не хватает монет!"
		return
	GameData.coins -= info.cost
	GameData.save_game()
	_spawn_building(gp, building_type)
	_update_ui()
	build_label.text = "Построено: " + info.name

func _spawn_building(gp: Vector2i, building_type: int) -> void:
	var info = BUILDINGS[building_type]
	# Простой цветной квадрат как плейсхолдер
	var rect := ColorRect.new()
	rect.color = info.color
	rect.size = Vector2(TILE_SIZE - 10, TILE_SIZE - 10)
	rect.position = _grid_to_pixel(gp) + Vector2(5, 5)
	add_child(rect)
	grid[gp.y][gp.x] = rect
	# Анимация появления
	rect.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(rect, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _grid_to_pixel(gp: Vector2i) -> Vector2:
	return BOARD_OFFSET + Vector2(gp.x * TILE_SIZE, gp.y * TILE_SIZE)

func _pixel_to_grid(p: Vector2) -> Vector2i:
	var local := (p - BOARD_OFFSET) / TILE_SIZE
	return Vector2i(floori(local.x), floori(local.y))

func _is_valid(gp: Vector2i) -> bool:
	return gp.x >= 0 and gp.x < GRID_SIZE and gp.y >= 0 and gp.y < GRID_SIZE
