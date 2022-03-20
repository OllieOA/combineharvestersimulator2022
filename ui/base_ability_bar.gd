extends HBoxContainer


export (NodePath) onready var icon_sprite = get_node(icon_sprite) as Sprite
export (NodePath) onready var timeout_bar = get_node(timeout_bar) as TextureProgress


var icon_frame := 0

func _ready() -> void:
	icon_sprite.frame = icon_frame
	
	pass
