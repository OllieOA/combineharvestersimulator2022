extends Node

var num_wheat_available := 0
var global_wheat_harvested := 0
var percentage_available := 100.0
var percentage_harvested_player := 0.0
var percentage_harvested_enemy := 0.0

onready var individual_wheat_harvested := {"player": 0, "enemy": 0}


func _process(delta: float) -> void:
	percentage_available = 100.0 - (float(global_wheat_harvested) / float(num_wheat_available) * 100.0)
	percentage_harvested_player = float(individual_wheat_harvested["player"]) / float(num_wheat_available) * 100.0
	percentage_harvested_enemy = float(individual_wheat_harvested["enemy"]) / float(num_wheat_available) * 100.0
	
