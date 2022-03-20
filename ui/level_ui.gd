extends Control

export (NodePath) onready var global_percentage_bar = get_node(global_percentage_bar) as TextureProgress
export (NodePath) onready var global_percentage_number = get_node(global_percentage_number) as Label
export (NodePath) onready var player_percentage_bar = get_node(player_percentage_bar) as TextureProgress
export (NodePath) onready var player_percentage_number = get_node(player_percentage_number) as Label
export (NodePath) onready var enemy_percentage_bar = get_node(enemy_percentage_bar) as TextureProgress
export (NodePath) onready var enemy_percentage_number = get_node(enemy_percentage_number) as Label


func _process(delta: float) -> void:
	global_percentage_bar.value = GameProgress.percentage_available
	global_percentage_number.set_text("%d%%" % GameProgress.percentage_available)
	
	player_percentage_bar.value = GameProgress.percentage_harvested_player
	player_percentage_number.set_text("%d%%" % GameProgress.percentage_harvested_player)
	
	enemy_percentage_bar.value = GameProgress.percentage_harvested_enemy
	enemy_percentage_number.set_text("%d%%" % GameProgress.percentage_harvested_enemy)
