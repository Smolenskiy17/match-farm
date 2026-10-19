extends Node2D

const GRID_SIZE := 6
const TILE_SIZE := 100
const BOARD_OFFSET := Vector2(60, 200)

const TILE_SCENE = preload("res://scenes/Tile.tscn")

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
			var t := randi() % 5
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
	if not _has_match_at(from) and not _has_match_at(to):
		_swap_back(from, to)

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
