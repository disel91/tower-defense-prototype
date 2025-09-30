extends Control

@onready var gold_label = $GameUI/StatsGroup/GoldLabel
@onready var lives_label = $GameUI/StatsGroup/LivesLabel
@onready var wave_label = $GameUI/StatsGroup/WaveLabel
@onready var start_wave_button = $GameUI/ButtonGroup/StartWaveButton
@onready var exit_button = $GameUI/ButtonGroup/ExitButton
@onready var game_status_label = $GameUI/StatusGroup/GameStatusLabel

var game_manager
var upgrade_menu


func _ready():
	game_manager = get_parent()
	start_wave_button.pressed.connect(_on_start_wave_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	update_gold(100)
	update_lives(10)
	update_wave(1)
	game_status_label.visible = false

func update_gold(amount: int):
	var interest_rate_percent = game_manager.get_current_interest_rate() * 100
	var next_interest = game_manager.calculate_interest(amount)

	gold_label.text = "Gold: " + str(amount) + " (+" + str(next_interest) + " next wave, " + str(interest_rate_percent) + "%)"

func update_lives(amount: int):
	lives_label.text = "Lives: " + str(amount)

func update_wave(wave: int):
	wave_label.text = "Wave: " + str(wave) + "/5"

func show_victory():
	game_status_label.text = "VICTORY!"
	game_status_label.modulate = Color.GREEN
	game_status_label.visible = true
	start_wave_button.disabled = true

func show_final_victory():
	game_status_label.text = "ALL WAVES COMPLETE!\nFINAL VICTORY!"
	game_status_label.modulate = Color.GOLD
	game_status_label.visible = true
	start_wave_button.disabled = true

func show_game_over():
	game_status_label.text = "GAME OVER"
	game_status_label.modulate = Color.RED
	game_status_label.visible = true
	start_wave_button.disabled = true

func enable_start_wave():
	start_wave_button.disabled = false

func _on_start_wave_pressed():
	game_manager.start_wave()
	start_wave_button.disabled = true

func _on_exit_pressed():
	get_tree().quit()

# Upgrade menu functions
func show_upgrade_menu(tower):
	print("DEBUG: HUD show_upgrade_menu called")
	if not upgrade_menu:
		print("DEBUG: Creating upgrade menu")
		create_upgrade_menu()
	else:
		print("DEBUG: Upgrade menu already exists")

	print("DEBUG: Updating upgrade menu")
	update_upgrade_menu(tower)
	upgrade_menu.visible = true
	print("DEBUG: Upgrade menu set to visible")

func hide_upgrade_menu():
	if upgrade_menu:
		upgrade_menu.visible = false

func create_upgrade_menu():
	# Create a container that will catch all mouse events
	upgrade_menu = Control.new()
	upgrade_menu.name = "UpgradeMenu"
	upgrade_menu.position = Vector2(50, 100)
	upgrade_menu.size = Vector2(250, 180)
	upgrade_menu.mouse_filter = Control.MOUSE_FILTER_STOP

	# Background panel
	var panel = Panel.new()
	panel.size = Vector2(250, 180)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	upgrade_menu.add_child(panel)

	# Content container
	var vbox = VBoxContainer.new()
	vbox.size = Vector2(250, 180)
	vbox.add_theme_constant_override("separation", 5)
	upgrade_menu.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "Tower Upgrades"
	title.add_theme_font_size_override("font_size", 16)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Tower info
	var info_label = Label.new()
	info_label.name = "InfoLabel"
	info_label.add_theme_font_size_override("font_size", 11)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(info_label)

	# Damage upgrade button
	var damage_button = Button.new()
	damage_button.name = "DamageButton"
	damage_button.add_theme_font_size_override("font_size", 11)
	damage_button.custom_minimum_size = Vector2(220, 25)
	damage_button.text = "Damage Upgrade (Loading...)"
	damage_button.disabled = false
	damage_button.mouse_filter = Control.MOUSE_FILTER_PASS
	if damage_button.pressed.connect(_on_damage_upgrade_pressed) == OK:
		print("DEBUG: Successfully connected damage button signal")
	else:
		print("DEBUG: FAILED to connect damage button signal")
	vbox.add_child(damage_button)

	# Speed upgrade button
	var speed_button = Button.new()
	speed_button.name = "SpeedButton"
	speed_button.add_theme_font_size_override("font_size", 11)
	speed_button.custom_minimum_size = Vector2(220, 25)
	speed_button.text = "Speed Upgrade (Loading...)"
	speed_button.disabled = false
	speed_button.mouse_filter = Control.MOUSE_FILTER_PASS
	if speed_button.pressed.connect(_on_speed_upgrade_pressed) == OK:
		print("DEBUG: Successfully connected speed button signal")
	else:
		print("DEBUG: FAILED to connect speed button signal")
	vbox.add_child(speed_button)

	add_child(upgrade_menu)
	upgrade_menu.visible = false
	print("DEBUG: Upgrade menu created and added to scene")

func update_upgrade_menu(tower):
	if not upgrade_menu:
		return

	var vbox = upgrade_menu.get_child(1)  # VBoxContainer is the second child
	var info_label = vbox.get_node("InfoLabel")
	var damage_button = vbox.get_node("DamageButton")
	var speed_button = vbox.get_node("SpeedButton")

	info_label.text = "Damage: " + str(tower.damage) + " (Lv." + str(tower.damage_level) + ")\n" + \
					 "Fire Rate: " + str("%.2f" % tower.fire_rate) + " (Lv." + str(tower.speed_level) + ")"

	var damage_cost = tower.get_damage_upgrade_cost()
	var speed_cost = tower.get_speed_upgrade_cost()

	if damage_cost > 0:
		damage_button.text = "Upgrade Damage (" + str(damage_cost) + " gold)"
		damage_button.disabled = game_manager.gold < damage_cost
	else:
		damage_button.text = "Damage MAX"
		damage_button.disabled = true

	if speed_cost > 0:
		speed_button.text = "Upgrade Speed (" + str(speed_cost) + " gold)"
		speed_button.disabled = game_manager.gold < speed_cost
	else:
		speed_button.text = "Speed MAX"
		speed_button.disabled = true

func _on_damage_upgrade_pressed():
	print("DEBUG: HUD damage upgrade button pressed")
	game_manager.upgrade_selected_tower_damage()

func _on_speed_upgrade_pressed():
	print("DEBUG: HUD speed upgrade button pressed")
	game_manager.upgrade_selected_tower_speed()

# Test function to verify callbacks work
func test_button_callbacks():
	print("DEBUG: Testing button callbacks manually")
	_on_damage_upgrade_pressed()
