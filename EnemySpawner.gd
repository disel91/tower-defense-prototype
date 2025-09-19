extends Node

var base_enemies = 6
var spawn_interval = 0.8
var enemies_spawned = 0
var spawn_timer = 0.0
var is_spawning = false
var current_wave = 1
var enemies_to_spawn = 6
var game_manager

func _ready():
	game_manager = get_parent()

func _process(delta):
	if is_spawning:
		spawn_timer -= delta
		if spawn_timer <= 0 and enemies_spawned < enemies_to_spawn:
			spawn_enemy()
			spawn_timer = spawn_interval
			enemies_spawned += 1

			if enemies_spawned >= enemies_to_spawn:
				is_spawning = false

func start_spawning(wave: int):
	current_wave = wave
	enemies_to_spawn = base_enemies + (wave - 1) * 3
	enemies_spawned = 0
	spawn_timer = 0.0
	is_spawning = true
	print("Starting wave ", wave, " - spawning ", enemies_to_spawn, " enemies")

func spawn_enemy():
	var enemy = preload("res://Enemy.tscn").instantiate()
	var spawn_pos = game_manager.get_path_waypoints()[0]
	enemy.position = spawn_pos
	enemy.set_wave_stats(current_wave)
	game_manager.add_enemy(enemy)
	print("Enemy spawned at ", spawn_pos, " with wave ", current_wave, " stats")