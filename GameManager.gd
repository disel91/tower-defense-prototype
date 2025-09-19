extends Node2D

enum GameState {
	BUILD,
	WAVE,
	GAME_OVER
}

const GRID_WIDTH = 12
const GRID_HEIGHT = 8
const TILE_SIZE = 64
const ISO_TILE_WIDTH = 64
const ISO_TILE_HEIGHT = 32

var current_state = GameState.BUILD
var gold = 100
var lives = 10
var current_wave = 1
var max_waves = 5

var grid = []
var path_waypoints = []
var enemies = []
var towers = []

@onready var hud = $HUD
@onready var enemy_spawner = $EnemySpawner

func grid_to_iso(grid_pos: Vector2i) -> Vector2:
	var x = (grid_pos.x - grid_pos.y) * (ISO_TILE_WIDTH / 2)
	var y = (grid_pos.x + grid_pos.y) * (ISO_TILE_HEIGHT / 2)
	return Vector2(x + 400, y + 100)

func iso_to_grid(world_pos: Vector2) -> Vector2i:
	var adjusted_pos = world_pos - Vector2(400, 100)
	var grid_x = round((adjusted_pos.x / (ISO_TILE_WIDTH / 2) + adjusted_pos.y / (ISO_TILE_HEIGHT / 2)) / 2)
	var grid_y = round((adjusted_pos.y / (ISO_TILE_HEIGHT / 2) - adjusted_pos.x / (ISO_TILE_WIDTH / 2)) / 2)
	return Vector2i(grid_x, grid_y)

func _ready():
	setup_grid()
	setup_path()

func setup_grid():
	grid = []
	for y in range(GRID_HEIGHT):
		var row = []
		for x in range(GRID_WIDTH):
			var iso_pos = grid_to_iso(Vector2i(x, y))
			row.append({
				"type": "buildable",
				"world_pos": iso_pos,
				"grid_pos": Vector2i(x, y),
				"occupied": false
			})
		grid.append(row)

func setup_path():
	path_waypoints = [
		Vector2i(0, 4),
		Vector2i(3, 4),
		Vector2i(3, 2),
		Vector2i(7, 2),
		Vector2i(7, 6),
		Vector2i(11, 6)
	]

	for i in range(len(path_waypoints) - 1):
		mark_path_tiles(path_waypoints[i], path_waypoints[i + 1])

func mark_path_tiles(start: Vector2i, end: Vector2i):
	var current = start

	while current != end:
		if current.y >= 0 and current.y < GRID_HEIGHT and current.x >= 0 and current.x < GRID_WIDTH:
			grid[current.y][current.x]["type"] = "path"

		if current.x < end.x:
			current.x += 1
		elif current.x > end.x:
			current.x -= 1
		elif current.y < end.y:
			current.y += 1
		elif current.y > end.y:
			current.y -= 1

	if end.y >= 0 and end.y < GRID_HEIGHT and end.x >= 0 and end.x < GRID_WIDTH:
		grid[end.y][end.x]["type"] = "path"

func _draw():
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var tile = grid[y][x]
			var iso_pos = grid_to_iso(Vector2i(x, y))

			var diamond_points = PackedVector2Array([
				iso_pos + Vector2(0, -ISO_TILE_HEIGHT/2),
				iso_pos + Vector2(ISO_TILE_WIDTH/2, 0),
				iso_pos + Vector2(0, ISO_TILE_HEIGHT/2),
				iso_pos + Vector2(-ISO_TILE_WIDTH/2, 0)
			])

			if tile["type"] == "path":
				draw_colored_polygon(diamond_points, Color.BROWN)
			else:
				draw_colored_polygon(diamond_points, Color.GRAY)

			draw_polyline(diamond_points + PackedVector2Array([diamond_points[0]]), Color.BLACK, 2)

	for i in range(len(path_waypoints)):
		var wp_pos = path_waypoints[i]
		var world_pos = grid_to_iso(wp_pos)
		draw_circle(world_pos, 8, Color.RED)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_click(event.position)

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_K:
			kill_all_enemies()
		elif event.keycode == KEY_R:
			restart_game()

func handle_click(pos: Vector2):
	if current_state == GameState.GAME_OVER:
		return

	var grid_pos = iso_to_grid(pos)
	var grid_x = grid_pos.x
	var grid_y = grid_pos.y

	if grid_x >= 0 and grid_x < GRID_WIDTH and grid_y >= 0 and grid_y < GRID_HEIGHT:
		var tile = grid[grid_y][grid_x]

		if tile["type"] == "buildable" and not tile["occupied"] and gold >= 50:
			place_tower(grid_x, grid_y)

func place_tower(grid_x: int, grid_y: int):
	gold -= 50
	grid[grid_y][grid_x]["occupied"] = true

	var tower = preload("res://Tower.tscn").instantiate()
	tower.position = grid_to_iso(Vector2i(grid_x, grid_y))
	add_child(tower)
	towers.append(tower)

	hud.update_gold(gold)
	print("Tower placed at (", grid_x, ", ", grid_y, "). Gold: ", gold)

func start_wave():
	if current_state == GameState.BUILD and current_wave <= max_waves:
		current_state = GameState.WAVE
		enemy_spawner.start_spawning(current_wave)
		hud.update_wave(current_wave)

func on_enemy_death(enemy):
	gold += 10
	enemies.erase(enemy)
	hud.update_gold(gold)

	if enemies.is_empty() and current_state == GameState.WAVE:
		current_state = GameState.BUILD
		current_wave += 1

		if current_wave > max_waves:
			hud.show_final_victory()
			print("All waves completed! Final Victory!")
		else:
			hud.enable_start_wave()
			print("Wave ", current_wave - 1, " completed!")

func on_enemy_exit(enemy):
	lives -= 1
	enemies.erase(enemy)
	hud.update_lives(lives)

	if lives <= 0:
		current_state = GameState.GAME_OVER
		hud.show_game_over()
	elif enemies.is_empty() and current_state == GameState.WAVE:
		current_state = GameState.BUILD
		current_wave += 1

		if current_wave > max_waves:
			hud.show_final_victory()
			print("All waves completed! Final Victory!")
		else:
			hud.enable_start_wave()
			print("Wave ", current_wave - 1, " completed!")

func get_path_waypoints():
	var world_waypoints = []
	for wp in path_waypoints:
		world_waypoints.append(grid_to_iso(wp))
	return world_waypoints

func add_enemy(enemy):
	enemies.append(enemy)
	add_child(enemy)

func get_enemies():
	return enemies

func kill_all_enemies():
	print("DEBUG: Killing all enemies")
	for enemy in enemies.duplicate():
		enemy.queue_free()
	enemies.clear()

func restart_game():
	print("DEBUG: Restarting game")
	get_tree().reload_current_scene()

func _process(_delta):
	queue_redraw()
