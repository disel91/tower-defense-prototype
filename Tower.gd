extends Node2D

var range_radius = 3.5 * 64
var damage = 10
var fire_rate = 0.6
var cooldown = 0.0
var game_manager

func _ready():
	game_manager = get_parent()

func _process(delta):
	cooldown -= delta

	if cooldown <= 0:
		var target = find_nearest_enemy()
		if target:
			attack(target)
			cooldown = fire_rate

func find_nearest_enemy():
	var enemies = game_manager.get_enemies()
	var nearest_enemy = null
	var nearest_distance = range_radius + 1

	for enemy in enemies:
		var distance = position.distance_to(enemy.position)
		if distance <= range_radius and distance < nearest_distance:
			nearest_enemy = enemy
			nearest_distance = distance

	return nearest_enemy

func attack(enemy):
	enemy.take_damage(damage)
	print("Tower attacked enemy for ", damage, " damage")

func _draw():
	draw_circle(Vector2.ZERO, 24, Color.BLUE)

	draw_circle(Vector2.ZERO, range_radius, Color.CYAN, false, 2)