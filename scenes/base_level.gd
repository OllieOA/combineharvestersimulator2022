class_name BaseLevel extends Node2D


export (NodePath) onready var player = get_node(player) as RigidBody2D
export (NodePath) onready var player_layer = get_node(player_layer) as Node2D
export (NodePath) onready var player_camera = get_node(player_camera) as ZoomingCamera2D

export (NodePath) onready var crop_tilemap = get_node(crop_tilemap) as TileMap
export (NodePath) onready var wheat_layer = get_node(wheat_layer) as YSort

export (PackedScene) onready var wheat_scene
export (PackedScene) onready var harvester_scene
export (PackedScene) onready var friend_scene

# Get crop logic
var wheat_placement_position = Vector2.ZERO
var wheat_tile_to_sprite := {}
var fence_corners

# World chunk logic
var chunk_size := 30
var map_pos
var wheat_to_harvest
var wheat_chunk_to_alter
var chunk

export var goal_percentage := 50.0
export var level_num := 0


func _ready() -> void:
	GameProgress.initialize_level(goal_percentage)
	_place_wheat()

	SignalBus.connect("attempt_harvest", self, "_handle_attempt_harvest")
	SignalBus.connect("wheat_harvested", self, "_handle_wheat_harvest")
	SignalBus.connect("ability_complete", self, "_handle_ability_complete")
	SignalBus.connect("spray_harvesters", self, "_handle_spray_harvesters")
	SignalBus.connect("stop_enemies", self, "stop_enemies")
	SignalBus.connect("spawn_farmhand", self, "_handle_spawn_farmhand")
	
	call_deferred("_setup_level")
	# 2022-03-21 - TODO: re-write this - velopman
	
func _setup_level():
	GameProgress.curr_level_num = level_num
	SignalBus.emit_signal("level_setup")
	GameProgress.game_active = true
	

# =-----------=
# Setup Methods
# =-----------=

func _place_wheat() -> void:
	# Find all crop spots and place tiles
	wheat_tile_to_sprite = {}
	for tile in crop_tilemap.crop_tiles:
		if crop_tilemap.get_cell_autotile_coord(tile.x, tile.y) in CropTilemap.VALID_AUTOTILES:
			var new_wheat = wheat_scene.instance()
			wheat_layer.add_child(new_wheat)
			
			wheat_placement_position = crop_tilemap.map_to_world(tile) + Vector2(0, -8)
			new_wheat.global_position = wheat_placement_position
			
			# Figure out what chunk this belongs to
			var chunk = Vector2(floor(tile.x / chunk_size), floor(tile.y / chunk_size))
			if not chunk in wheat_tile_to_sprite:
				wheat_tile_to_sprite[chunk] = {}
				
			wheat_tile_to_sprite[chunk][tile] = [new_wheat, true]

	for key in wheat_tile_to_sprite:
		GameProgress.num_wheat_available += len(wheat_tile_to_sprite[key])


func _handle_attempt_harvest(point: Vector2, harvester: BaseHarvester) -> void:
	map_pos = crop_tilemap.world_to_map(point)
	chunk = Vector2(floor(map_pos.x / chunk_size), floor(map_pos.y / chunk_size))
	
	wheat_chunk_to_alter = wheat_tile_to_sprite.get(chunk, null)
	if wheat_chunk_to_alter != null:
		wheat_to_harvest = wheat_chunk_to_alter.get(map_pos, null)
		if wheat_to_harvest != null:
			if wheat_to_harvest[1]:
				wheat_to_harvest[0].harvest_wheat(harvester)
				wheat_tile_to_sprite[chunk][map_pos][1] = false


func _handle_wheat_harvest(wheat, harvester) -> void:
	GameProgress.global_wheat_harvested += 1
	GameProgress.percentage_available = float(GameProgress.global_wheat_harvested) / float(GameProgress.num_wheat_available) * 100.0
	
	if harvester.is_in_group("player_harvester"):
		GameProgress.individual_wheat_harvested["player"] += 1
	elif harvester.is_in_group("enemy_harvester"):
		GameProgress.individual_wheat_harvested["enemy"] += 1
	

func _handle_ability_complete(reset_method, reset_group):
	get_tree().call_group(reset_group, reset_method)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("reset"):
		SceneTransition.goto_scene("res://scenes/title_screen.tscn")


func stop_enemies():
	get_tree().call_group("enemy", "stop_movement")
	SignalBus.emit_signal("add_ui_turn_countdown", PowerupProperties.Type.STOP, 2, "start_movement", "enemy")


func _handle_spray_harvesters(spawn_pos, spawn_rot, number):
	var angle_increment = 360.0/float(number)
	
	for n in range(number):
		var new_harvester = harvester_scene.instance()
		new_harvester.scale = Vector2(0.6, 0.8)
		player_layer.add_child(new_harvester)
		
		new_harvester.global_position = spawn_pos
		new_harvester.global_rotation_degrees = n * angle_increment
		var launch_vector = Vector2(cos(deg2rad(n * angle_increment)), sin(deg2rad(n * angle_increment))).normalized()
		new_harvester.spawn_and_launch(launch_vector)


func _handle_spawn_farmhand(spawn_pos, spawn_rot):
	var new_friend = friend_scene.instance()
	player_layer.add_child(new_friend)
	var new_friend_alias = "new_friend_%d" % GameProgress.friend_spawn_num
	GameProgress.friend_spawn_num += 1
	new_friend.add_to_group(new_friend_alias)
	
	new_friend.global_position = spawn_pos - 20 * Vector2(cos(spawn_rot), sin(spawn_rot))
	SignalBus.emit_signal("add_ui_turn_countdown", PowerupProperties.Type.HAND, 4, "queue_free", new_friend_alias)
