extends Control

export (NodePath) onready var crop_tilemap = get_node(crop_tilemap) as TileMap
export (NodePath) onready var wheat_layer = get_node(wheat_layer) as YSort
export (PackedScene) var wheat_scene

export (NodePath) onready var level1_button = get_node(level1_button) as TextureButton
export (NodePath) onready var level2_button = get_node(level2_button) as TextureButton
export (NodePath) onready var level3_button = get_node(level3_button) as TextureButton
export (NodePath) onready var level4_button = get_node(level4_button) as TextureButton
export (NodePath) onready var level5_button = get_node(level5_button) as TextureButton
export (NodePath) onready var level6_button = get_node(level6_button) as TextureButton


var wheat_tile_to_sprite
var wheat_placement_position

func _ready() -> void:
	SignalBus.connect("settings_pressed", self, "_disable_buttons")
	SignalBus.connect("settings_unpressed", self, "_enable_buttons")
	GameProgress.game_active = false
	_place_wheat()


func _enable_buttons():
	level1_button.disabled = false
	level2_button.disabled = false
	level3_button.disabled = false
	level4_button.disabled = false
	level5_button.disabled = false
	level6_button.disabled = false
	
func _disable_buttons():
	level1_button.disabled = true
	level2_button.disabled = true
	level3_button.disabled = true
	level4_button.disabled = true
	level5_button.disabled = true
	level6_button.disabled = true


func _on_LevelButton1_pressed() -> void:
	SceneTransition.goto_scene("res://scenes/level_1.tscn")


func _on_LevelButton2_pressed() -> void:
	SceneTransition.goto_scene("res://scenes/level_2.tscn")


func _on_LevelButton3_pressed() -> void:
	SceneTransition.goto_scene("res://scenes/level_3.tscn")


func _on_LevelButton4_pressed() -> void:
	SceneTransition.goto_scene("res://scenes/level_4.tscn")


func _on_LevelButton5_pressed() -> void:
	SceneTransition.goto_scene("res://scenes/level_5.tscn")


func _on_LevelButton6_pressed() -> void:
	SceneTransition.goto_scene("res://scenes/level_6.tscn")


func _place_wheat() -> void:
	# Find all crop spots and place tiles
	wheat_tile_to_sprite = {}
	for tile in crop_tilemap.get_used_cells():
		if crop_tilemap.get_cell_autotile_coord(tile.x, tile.y) in CropTilemap.VALID_AUTOTILES:
			var new_wheat = wheat_scene.instance()
			wheat_layer.add_child(new_wheat)
			
			wheat_placement_position = crop_tilemap.map_to_world(tile) + Vector2(0, -8)
			new_wheat.global_position = wheat_placement_position
