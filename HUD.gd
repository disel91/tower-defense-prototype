extends Control

@onready var gold_label = $GameUI/StatsGroup/GoldLabel
@onready var lives_label = $GameUI/StatsGroup/LivesLabel
@onready var wave_label = $GameUI/StatsGroup/WaveLabel
@onready var start_wave_button = $GameUI/ButtonGroup/StartWaveButton
@onready var exit_button = $GameUI/ButtonGroup/ExitButton
@onready var game_status_label = $GameUI/StatusGroup/GameStatusLabel

var game_manager

func _ready():
	game_manager = get_parent()
	start_wave_button.pressed.connect(_on_start_wave_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	update_gold(100)
	update_lives(10)
	update_wave(1)
	game_status_label.visible = false

func update_gold(amount: int):
	gold_label.text = "Gold: " + str(amount)

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
