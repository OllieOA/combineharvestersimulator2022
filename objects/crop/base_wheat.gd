class_name BaseWheat extends Node2D

export (NodePath) onready var wheat_sprite = get_node(wheat_sprite) as Sprite
export (NodePath) onready var kill_animator = get_node(kill_animator) as AnimationPlayer

var rng = RandomNumberGenerator.new()
var frame_number: int


func _ready() -> void:
	rng.randomize()
	wheat_sprite.material.set_shader_param("shader_param/global_pos", global_position)
	frame_number = rng.randi_range(0, 3)
	wheat_sprite.frame = frame_number
	kill_animator.stop()


func harvest_wheat(harvester):
	SignalBus.emit_signal("wheat_harvested", self, harvester)
	call_deferred("_deferred_harvest_wheat", harvester)


func _deferred_harvest_wheat(harvester):
	_kill_wheat()


func _kill_wheat() -> void:
	kill_animator.play("kill_wheat")
	yield(kill_animator, "animation_finished")
#	queue_free()
	wheat_sprite.hide()
