extends Control

export (NodePath) onready var progress_bar_container = get_node(progress_bar_container) as MarginContainer
export (NodePath) onready var global_percentage_bar = get_node(global_percentage_bar) as TextureProgress
export (NodePath) onready var global_percentage_number = get_node(global_percentage_number) as Label
export (NodePath) onready var player_percentage_bar = get_node(player_percentage_bar) as TextureProgress
export (NodePath) onready var player_percentage_number = get_node(player_percentage_number) as Label
export (NodePath) onready var player_percentage_goal_tick = get_node(player_percentage_goal_tick) as TextureRect
export (NodePath) onready var enemy_percentage_bar = get_node(enemy_percentage_bar) as TextureProgress
export (NodePath) onready var enemy_percentage_number = get_node(enemy_percentage_number) as Label

export (NodePath) onready var ability_bar_stack = get_node(ability_bar_stack) as VBoxContainer

export (NodePath) onready var return_box = get_node(return_box) as MarginContainer
export (NodePath) onready var return_text = get_node(return_text) as Label

export (PackedScene) var ability_bar_base


func _ready() -> void:
	SignalBus.connect("add_ui_turn_countdown", self, "_handle_ability_bar")
	SignalBus.connect("level_setup", self, "_handle_level_setup")
	
	SignalBus.connect("level_won", self, "_handle_level_won")
	SignalBus.connect("level_lost", self, "_handle_level_lost")


func _process(delta: float) -> void:
	if GameProgress.game_active:
		global_percentage_bar.value = GameProgress.percentage_available
		global_percentage_number.set_text("%.1f%%" % GameProgress.percentage_available)
		
		player_percentage_bar.value = GameProgress.percentage_harvested_player
		player_percentage_number.set_text("%.1f%% (GOAL %.1f%%)" % [GameProgress.percentage_harvested_player, GameProgress.goal_player_percentage])
		
		enemy_percentage_bar.value = GameProgress.percentage_harvested_enemy
		enemy_percentage_number.set_text("%.1f%%" % GameProgress.percentage_harvested_enemy)


func _handle_ability_bar(type, turns, reset_method_name, reset_method_group):
	var new_ability_bar = ability_bar_base.instance()
	new_ability_bar.icon_texture = PowerupProperties.powerup_database[type]["icon_texture"]
	new_ability_bar.num_ticks = turns
	new_ability_bar.reset_method = reset_method_name
	new_ability_bar.reset_group = reset_method_group
	
	ability_bar_stack.add_child(new_ability_bar)


func _handle_level_setup():
	player_percentage_goal_tick.anchor_left = GameProgress.goal_player_percentage / 100


func _hide_ui():
	ability_bar_stack.hide()
	progress_bar_container.hide()


func _handle_level_won():
	_hide_ui()
	return_text.set_text("You win!")
	return_box.show()


func _handle_level_lost():
	_hide_ui()
	return_text.set_text("You lose!")
	return_box.show()

func _on_GameEndButton_pressed() -> void:
	SceneTransition.goto_scene("res://scenes/title_screen.tscn")


func _on_NextButton_pressed() -> void:
	if GameProgress.curr_level_num + 1 > 6:
		SceneTransition.goto_scene("res://scenes/title_screen.tscn")
	else:
		var next_level = "res://scenes/level_%d.tscn" % (GameProgress.curr_level_num + 1)
		SceneTransition.goto_scene(next_level)
