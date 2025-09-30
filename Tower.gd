extends Node2D

var range_radius = 3.5 * 64
var base_damage = 10
var damage = 10
var base_fire_rate = 0.6
var fire_rate = 0.6
var cooldown = 0.0
var game_manager

# Upgrade system
var damage_level = 1
var speed_level = 1
var max_upgrade_level = 5
var damage_upgrade_cost = 30
var speed_upgrade_cost = 25
var is_selected = false

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

# Upgrade system functions
func upgrade_damage():
	var cost = get_damage_upgrade_cost()
	print("DEBUG: Trying to upgrade damage. Cost: ", cost, ", Current gold: ", game_manager.gold, ", Level: ", damage_level)
	if damage_level < max_upgrade_level and cost > 0 and game_manager.gold >= cost:
		game_manager.gold -= cost
		damage_level += 1
		damage = base_damage + (damage_level - 1) * 8
		game_manager.hud.update_gold(game_manager.gold)
		print("Damage upgraded to level ", damage_level, " (", damage, " damage). Gold now: ", game_manager.gold)
		return true
	else:
		print("DEBUG: Upgrade failed. Max level? ", damage_level >= max_upgrade_level, ", Cost valid? ", cost > 0, ", Can afford? ", game_manager.gold >= cost)
	return false

func upgrade_speed():
	var cost = get_speed_upgrade_cost()
	print("DEBUG: Trying to upgrade speed. Cost: ", cost, ", Current gold: ", game_manager.gold, ", Level: ", speed_level)
	if speed_level < max_upgrade_level and cost > 0 and game_manager.gold >= cost:
		game_manager.gold -= cost
		speed_level += 1
		fire_rate = base_fire_rate * (1.0 - (speed_level - 1) * 0.15)
		game_manager.hud.update_gold(game_manager.gold)
		print("Speed upgraded to level ", speed_level, " (", fire_rate, " fire rate). Gold now: ", game_manager.gold)
		return true
	else:
		print("DEBUG: Speed upgrade failed. Max level? ", speed_level >= max_upgrade_level, ", Cost valid? ", cost > 0, ", Can afford? ", game_manager.gold >= cost)
	return false

func get_damage_upgrade_cost() -> int:
	if damage_level >= max_upgrade_level:
		return -1
	return damage_upgrade_cost + (damage_level - 1) * 10

func get_speed_upgrade_cost() -> int:
	if speed_level >= max_upgrade_level:
		return -1
	return speed_upgrade_cost + (speed_level - 1) * 10

func can_be_clicked(click_pos: Vector2) -> bool:
	return position.distance_to(click_pos) <= 32

func select():
	is_selected = true
	print("DEBUG: Tower selected, range_radius = ", range_radius)
	queue_redraw()

func deselect():
	is_selected = false
	print("DEBUG: Tower deselected")
	queue_redraw()

func _draw():
	var tower_color = Color.BLUE
	if is_selected:
		tower_color = Color.YELLOW
		draw_circle(Vector2.ZERO, 32, Color.WHITE, false, 3)
		print("DEBUG: Drawing selected tower with range circle, range_radius = ", range_radius)

	draw_circle(Vector2.ZERO, 24, tower_color)

	if is_selected:
		draw_circle(Vector2.ZERO, range_radius, Color.CYAN, false, 2)
