class_name BaseLevel extends Node2D


export (NodePath) onready var player = get_node(player) as RigidBody2D

export (NodePath) onready var crop_tilemap = get_node(crop_tilemap) as TileMap
export (NodePath) onready var wheat_layer = get_node(wheat_layer) as YSort

export (PackedScene) onready var wheat_scene

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


func _ready() -> void:
	_place_wheat()
#	_get_enemies()
	SignalBus.connect("attempt_harvest", self, "_handle_attempt_harvest")
	SignalBus.connect("wheat_harvested", self, "_handle_wheat_harvest")


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
	
	if harvester.is_in_group("player"):
		GameProgress.individual_wheat_harvested["player"] += 1
	else:
		GameProgress.individual_wheat_harvested["enemy"] += 1
	
