class_name CropTilemap extends TileMap

var crop_rect : Rect2
var crop_tiles : Array


const VALID_AUTOTILES = [
	Vector2(1, 1),
	Vector2(1, 2),
	Vector2(2, 1),
	Vector2(2, 2)
]

const CORNER_AUTOTILES = [
	# Outer Corners
	Vector2(0, 0),
	Vector2(0, 3),
	Vector2(3, 0),
	Vector2(3, 3),
	# Inner corners
	Vector2(0, 4),
	Vector2(0, 5),
	Vector2(1, 4),
	Vector2(1, 5),
	Vector2(2, 4),
	Vector2(2, 5),
	Vector2(3, 4),
	Vector2(3, 5),
]

var tilemap_rect


func _ready() -> void:
	crop_rect = get_used_rect()
	crop_tiles = get_used_cells()
	

