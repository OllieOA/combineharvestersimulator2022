class_name BasePowerup extends Node2D

export (Resource) var powerup_properties
export (PowerupProperties.Type) var powerup_type

export (NodePath) onready var border = get_node(border) as Sprite
export (NodePath) onready var icon = get_node(icon) as Sprite
export (NodePath) onready var bounce = get_node(bounce) as AnimationPlayer
export (NodePath) onready var activation_area = get_node(activation_area) as Area2D

export (NodePath) onready var absorb_sound = get_node(absorb_sound) as AudioStreamPlayer

func _ready() -> void:
	border.self_modulate = powerup_properties.powerup_database[powerup_type]["colour"]
	icon.frame = powerup_properties.powerup_database[powerup_type]["icon_frame"]
	bounce.play("pulse")
	
	

func _on_AbsorbArea_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.call(powerup_properties.powerup_database[powerup_type]["target_method"])
		call_deferred("_kill_powerup")


func _kill_powerup():
	absorb_sound.play()
	border.hide()
	icon.hide()
	bounce.stop()
	activation_area.monitoring = false
