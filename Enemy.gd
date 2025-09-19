extends CharacterBody2D

var base_hp = 40
var hp = 40
var max_hp = 40
var speed = 64.0
var waypoints = []
var current_waypoint_index = 0
var wave = 1
var game_manager

func set_wave_stats(wave_num: int):
	wave = wave_num
	max_hp = base_hp + (wave - 1) * 20
	hp = max_hp

func _ready():
	game_manager = get_parent()
	waypoints = game_manager.get_path_waypoints()

func _physics_process(delta):
	if current_waypoint_index >= waypoints.size():
		return

	var target = waypoints[current_waypoint_index]
	var direction = (target - position).normalized()

	if position.distance_to(target) < 5:
		current_waypoint_index += 1
		if current_waypoint_index >= waypoints.size():
			game_manager.on_enemy_exit(self)
			queue_free()
			return

	velocity = direction * speed
	move_and_slide()

func take_damage(damage: int):
	hp -= damage
	if hp <= 0:
		game_manager.on_enemy_death(self)
		queue_free()

func _draw():
	draw_rect(Rect2(-16, -16, 32, 32), Color.RED)

	var bar_width = 32
	var bar_height = 4
	var health_percentage = float(hp) / float(max_hp)

	draw_rect(Rect2(-bar_width/2, -24, bar_width, bar_height), Color.BLACK)
	draw_rect(Rect2(-bar_width/2, -24, bar_width * health_percentage, bar_height), Color.GREEN)

func _process(_delta):
	queue_redraw()