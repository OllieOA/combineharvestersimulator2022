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
				
			if Input.is_action_pressed("left_click"):
				launch_bar.value = position.distance_to(get_global_mouse_position())/3.5
				
			if Input.is_action_just_released("left_click"):
				set_linear_damp(1)
				state = State.LAUNCHED
				print("DEBUG: LAUNCH BAR VALUE ", launch_bar.value)
				apply_impulse(Vector2.ZERO, (global_position - get_global_mouse_position()).normalized() * launch_bar.value * max_launch_force)

		State.LAUNCHED:
			launch_bar.hide()
			chaff.emitting = true
			state = State.COASTING
		
		State.COASTING:
			# Push rotation in direction of travel
			global_rotation = lerp_angle(global_rotation, linear_velocity.angle(), 0.2)
			_check_wall_collision()
			if slowed_enough:
				set_linear_damp(10)
				launch_bar.value = 0
				chaff.emitting = false
				state = State.LAUNCHING


func _check_wall_collision():
	for body in get_colliding_bodies():
		if body.is_in_group("crop"):
			pass


#	harvester.change_size(1.5, 5)

# =-------------=
# Powerup methods
# =-------------=

func boost():
	pass


func spray():
	pass


func stop():
	pass


func spawn_farmhand():
	pass
	
	
func double_size():
	harvester.change_size(2, 3)
	
	
func halve_size():
	pass
