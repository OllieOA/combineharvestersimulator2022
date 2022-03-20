extends RigidBody2D

export (NodePath) onready var launch_bar = get_node(launch_bar) as TextureProgress
export (NodePath) onready var harvester = get_node(harvester) as BaseHarvester
export (NodePath) onready var chaff = get_node(chaff) as Particles2D


enum State {
	LAUNCHING,
	LAUNCHED,
	COASTING,
}
var state = State.LAUNCHING

var max_launch_force = 150
var slowed_enough := false

var iframe_enabled := false
var size_mod_active := false


func _ready() -> void:
	launch_bar.hide()
	chaff.emitting = false


func _physics_process(delta: float) -> void:
	slowed_enough = linear_velocity.length() < 50
	
	match state:
		State.LAUNCHING:
			rotation = lerp_angle(rotation, (get_global_mouse_position() - position).angle() + PI, 0.3)
			if not launch_bar.visible:
				launch_bar.show()
			
			if GameProgress.game_active:
				if Input.is_action_pressed("left_click"):
					launch_bar.value = position.distance_to(get_global_mouse_position()) / 3.5
					
				if Input.is_action_just_released("left_click"):
					set_linear_damp(1)
					state = State.LAUNCHED
					apply_central_impulse((global_position - get_global_mouse_position()).normalized() * launch_bar.value * max_launch_force)

		State.LAUNCHED:
			SignalBus.emit_signal("player_launched")
			launch_bar.hide()
			chaff.emitting = true
			state = State.COASTING
		
		State.COASTING:
			# Push rotation in direction of travel
			global_rotation = lerp_angle(global_rotation, linear_velocity.angle(), 0.2)
			if slowed_enough:
				set_linear_damp(10)
				launch_bar.value = 0
				chaff.emitting = false
				SignalBus.emit_signal("turn_complete")
				state = State.LAUNCHING


# =-------------=
# Powerup methods
# =-------------=

func boost():
	apply_central_impulse(linear_velocity.normalized() * 40 * max_launch_force)


func spray():
	# Spawn 8 mini harvesters
	SignalBus.emit_signal("spray_harvesters", global_position, global_rotation_degrees, 8)


func stop():
	SignalBus.emit_signal("stop_enemies")


func spawn_farmhand():
	SignalBus.emit_signal("spawn_farmhand", global_position, global_rotation)
	
	
func double_size():
	harvester.change_size(2, 3, PowerupProperties.Type.DOUBLE, "player")
	
	
func halve_size():
	harvester.change_size(0.5, 3, PowerupProperties.Type.HALVE, "player")


func reset_size():
	harvester.change_size(1, -1, null, null)
	# BOOBIES
