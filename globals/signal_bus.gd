extends Node

signal wheat_harvested(wheat_object, harvester)
signal attempt_harvest(wheat_position)
signal add_ui_turn_countdown(type, turns, reset_method_name, reset_method_group)
signal ability_complete(ability_id)
signal turn_complete
signal spray_harvesters(spawn_pos, spawn_rot, number)
signal spawn_farmhand(spawn_pos, spawn_rot)
signal stop_enemies
signal player_launched
signal level_setup

signal level_won
signal level_lost

signal settings_pressed
signal settings_unpressed
