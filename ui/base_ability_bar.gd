extends HBoxContainer


export (NodePath) onready var icon_sprite = get_node(icon_sprite) as TextureRect
export (NodePath) onready var timeout_bar = get_node(timeout_bar) as TextureProgress
export (NodePath) onready var tick_texture = get_node(tick_texture) as TextureRect

var icon_texture := preload("res://ui/powerup_icons_small_boost.png")
var num_ticks := 0

var reset_method := ""
var reset_group := ""

func _ready() -> void:
	icon_sprite.texture = icon_texture
	_add_ticks()
	SignalBus.connect("turn_complete", self, "_decrement_bar")
	timeout_bar.max_value = num_ticks
	timeout_bar.value = timeout_bar.max_value


func _add_ticks() -> void:
	var tick_container = tick_texture.get_parent()
	for _n in range(num_ticks - 1):
		var next_tick = tick_texture.duplicate()
		tick_container.add_child(next_tick)


func _decrement_bar() -> void:
	timeout_bar.value -= timeout_bar.max_value / num_ticks
	print(timeout_bar.value)
	if timeout_bar.value < 1:
		SignalBus.emit_signal("ability_complete", reset_method, reset_group)
		_kill_ability_bar()

func _kill_ability_bar() -> void:
	queue_free()
