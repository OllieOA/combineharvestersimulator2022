extends Node

var num_wheat_available := 0
var global_wheat_harvested := 0
var percentage_available := 100.0
var percentage_harvested_player := 0.0
var percentage_harvested_enemy := 0.0

var curr_level_num := 0

var goal_player_percentage := 100.0
var game_active := true

onready var individual_wheat_harvested := {"player": 0, "enemy": 0}
export (NodePath) onready var music_fade = get_node(music_fade) as AnimationPlayer

var friend_spawn_num := 0

func _ready() -> void:
	call_deferred("_start_tunes")


func _start_tunes():
	$Music.play()
	music_fade.play("FadeIn")


func _process(delta: float) -> void:
	if game_active:
		percentage_available = 100.0 - (float(global_wheat_harvested) / float(num_wheat_available) * 100.0)
		percentage_harvested_player = float(individual_wheat_harvested["player"]) / float(num_wheat_available) * 100.0
		percentage_harvested_enemy = float(individual_wheat_harvested["enemy"]) / float(num_wheat_available) * 100.0
		
		if percentage_harvested_player > goal_player_percentage:
			game_active = false
			SignalBus.emit_signal("level_won")
			
		if (goal_player_percentage - percentage_harvested_player) > percentage_available:
			game_active = false
			SignalBus.emit_signal("level_lost")


func initialize_level(goal_percentage) -> void:
	num_wheat_available = 0
	global_wheat_harvested = 0
	percentage_available = 100.0
	percentage_harvested_enemy = 0.0
	percentage_harvested_player = 0.0
	
	individual_wheat_harvested = {"player": 0, "enemy": 0}
	
	goal_player_percentage = goal_percentage
