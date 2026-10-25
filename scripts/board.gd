extends Node2D

const GRID_SIZE := 6
const TILE_SIZE := 100
const BOARD_OFFSET := Vector2(60, 200)

const TILE_SCENE = preload("res://scenes/Tile.tscn")
@onready var match_sound: AudioStreamPlayer = $MatchSound
@onready var swap_sound: AudioStreamPlayer = $SwapSound
var grid: Array = []

var selected_tile: Tile = null
var drag_start: Vector2 = Vector2.ZERO
var is_dragging := false

func _ready() -> void:
	_init_grid()
	_fill_board()

func _init_grid() -> void:
	grid.clear()
	for y in GRID_SIZE:
		var row := []
		row.resize(GRID_SIZE)
		grid.append(row)

func _fill_board() -> void:
	for y in GRID_SIZE:
		for x in GRID_SIZE:
			var tile := TILE_SCENE.instantiate() as Tile
			add_child(tile)
			var pos := Vector2i(x, y)
			var t: int = randi() % 5
			tile.setup(t, pos)
			tile.position = _grid_to_pixel(pos)
			grid[y][x] = tile

func _grid_to_pixel(gp: Vector2i) -> Vector2:
	return BOARD_OFFSET + Vector2(gp.x * TILE_SIZE, gp.y * TILE_SIZE)

func _pixel_to_grid(p: Vector2) -> Vector2i:
	var local := (p - BOARD_OFFSET) / TILE_SIZE
	return Vector2i(roundi(local.x), roundi(local.y))

func _is_valid(gp: Vector2i) -> bool:
	return gp.x >= 0 and gp.x < GRID_SIZE and gp.y >= 0 and gp.y < GRID_SIZE

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			_on_press(event.position)
		else:
			_on_release(event.position)

func _on_press(pos: Vector2) -> void:
	var gp := _pixel_to_grid(pos)
	if not _is_valid(gp):
		return
	selected_tile = grid[gp.y][gp.x]
	drag_start = pos
	is_dragging = true

func _on_release(pos: Vector2) -> void:
	if not is_dragging or selected_tile == null:
		return
	is_dragging = false
	var delta := pos - drag_start
	if delta.length() < 30:
		selected_tile = null
		return
	var dir := Vector2i.ZERO
	if abs(delta.x) > abs(delta.y):
		dir = Vector2i(1 if delta.x > 0 else -1, 0)
	else:
		dir = Vector2i(0, 1 if delta.y > 0 else -1)
	var from: Vector2i = selected_tile.grid_pos
	var to: Vector2i = from + dir
	selected_tile = null
	if not _is_valid(to):
		return
	_try_swap(from, to)

func _try_swap(from: Vector2i, to: Vector2i) -> void:
	var a: Tile = grid[from.y][from.x]
	var b: Tile = grid[to.y][to.x]
	if a == null or b == null:
		return

	grid[from.y][from.x] = b
	grid[to.y][to.x] = a
	a.grid_pos = to
	b.grid_pos = from

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(a, "position", _grid_to_pixel(to), 0.15)
	tween.tween_property(b, "position", _grid_to_pixel(from), 0.15)
	await tween.finished
	
	swap_sound.play()

	if _has_match_at(from) or _has_match_at(to):
		await _resolve_matches()
	else:
		await _swap_back(from, to)


func _swap_back(from: Vector2i, to: Vector2i) -> void:
	var a: Tile = grid[to.y][to.x]
	var b: Tile = grid[from.y][from.x]
	grid[from.y][from.x] = a
	grid[to.y][to.x] = b
	a.grid_pos = from
	b.grid_pos = to
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(a, "position", _grid_to_pixel(from), 0.15)
	tween.tween_property(b, "position", _grid_to_pixel(to), 0.15)
	await tween.finished

func _has_match_at(gp: Vector2i) -> bool:
	var tile: Tile = grid[gp.y][gp.x]
	if tile == null:
		return false
	return _count_line(gp, Vector2i(1, 0)) >= 3 or _count_line(gp, Vector2i(0, 1)) >= 3

func _count_line(gp: Vector2i, dir: Vector2i) -> int:
	var tile: Tile = grid[gp.y][gp.x]
	if tile == null:
		return 0
	var t := tile.type
	var count := 1
	var p := gp + dir
	while _is_valid(p) and grid[p.y][p.x] != null and grid[p.y][p.x].type == t:
		count += 1
		p += dir
	p = gp - dir
	while _is_valid(p) and grid[p.y][p.x] != null and grid[p.y][p.x].type == t:
		count += 1
		p -= dir
	return count

# --- Удаление, падение, рефилл, каскады ---

var score: int = 0

func _resolve_matches() -> void:
	# Ищем все совпадения на поле
	var to_remove: Array = _find_all_matches()
	if to_remove.is_empty():
		return

	# Считаем очки (15 за фишку)
	score += to_remove.size() * 15
	print("Очки: ", score)
	match_sound.play()
	# Анимация удаления
	for tile in to_remove:
		var tween := create_tween()
		tween.tween_property(tile, "scale", Vector2.ZERO, 0.15)
		tile.explode()
		tween.tween_callback(tile.queue_free)
		grid[tile.grid_pos.y][tile.grid_pos.x] = null

	# Ждём, пока анимация удаления закончится
	await get_tree().create_timer(0.2).timeout

	# Падение и рефилл
	await _apply_gravity()
	await _refill_board()

	# Каскад: проверяем ещё раз
	await _resolve_matches()

func _find_all_matches() -> Array:
	var result: Array = []
	var seen: Dictionary = {}
	for y in GRID_SIZE:
		for x in GRID_SIZE:
			var gp := Vector2i(x, y)
			if grid[y][x] == null:
				continue
			if _has_match_at(gp):
				# Собираем всю линию
				var t: int = grid[y][x].type
				# Горизонталь
				var h_start := x
				while h_start > 0 and grid[y][h_start - 1] != null and grid[y][h_start - 1].type == t:
					h_start -= 1
				var h_end := x
				while h_end < GRID_SIZE - 1 and grid[y][h_end + 1] != null and grid[y][h_end + 1].type == t:
					h_end += 1
				if h_end - h_start + 1 >= 3:
					for i in range(h_start, h_end + 1):
						var key := Vector2i(i, y)
						if not seen.has(key):
							seen[key] = true
							result.append(grid[y][i])
				# Вертикаль
				var v_start := y
				while v_start > 0 and grid[v_start - 1][x] != null and grid[v_start - 1][x].type == t:
					v_start -= 1
				var v_end := y
				while v_end < GRID_SIZE - 1 and grid[v_end + 1][x] != null and grid[v_end + 1][x].type == t:
					v_end += 1
				if v_end - v_start + 1 >= 3:
					for j in range(v_start, v_end + 1):
						var key := Vector2i(x, j)
						if not seen.has(key):
							seen[key] = true
							result.append(grid[j][x])
	return result

func _apply_gravity() -> void:
	# Для каждого столбца: сдвигаем все фишки вниз, заполняя пустоты
	for x in GRID_SIZE:
		var write_y := GRID_SIZE - 1
		for y in range(GRID_SIZE - 1, -1, -1):
			if grid[y][x] != null:
				if write_y != y:
					grid[write_y][x] = grid[y][x]
					grid[y][x] = null
					grid[write_y][x].grid_pos = Vector2i(x, write_y)
				write_y -= 1

	# Анимация падения
	var tweens: Array = []
	for y in GRID_SIZE:
		for x in GRID_SIZE:
			var tile: Tile = grid[y][x]
			if tile == null:
				continue
			var target := _grid_to_pixel(Vector2i(x, y))
			if tile.position != target:
				var tween := create_tween()
				tween.tween_property(tile, "position", target, 0.2)
				tweens.append(tween)
	for tween in tweens:
		await tween.finished

func _refill_board() -> void:
	# Заполняем пустые верхние клетки новыми фишками
	var tweens: Array = []
	for x in GRID_SIZE:
		var empty_count := 0
		for y in GRID_SIZE:
			if grid[y][x] == null:
				empty_count += 1
		# Создаём новые фишки над полем
		for i in empty_count:
			var y := empty_count - 1 - i  # сверху вниз
			var tile := TILE_SCENE.instantiate() as Tile
			add_child(tile)
			var t := randi() % 5
			tile.setup(t, Vector2i(x, y))
			# Стартовая позиция — выше поля
			var start_pos := _grid_to_pixel(Vector2i(x, y)) + Vector2(0, -TILE_SIZE * (empty_count + 1))
			tile.position = start_pos
			grid[y][x] = tile
			var target := _grid_to_pixel(Vector2i(x, y))
			var tween := create_tween()
			tween.tween_property(tile, "position", target, 0.25)
			tweens.append(tween)
	for tween in tweens:
		await tween.finished
signal game_finished(final_score: int)

var time_left: float = 45.0
var is_playing: bool = true

func _process(delta: float) -> void:
	if not is_playing:
		return
	time_left -= delta
	if time_left <= 0:
		_finish_game()

func _finish_game() -> void:
	if not is_playing:
		return
	is_playing = false
	game_finished.emit(score)
