class_name BaseHarvester extends Sprite

export (NodePath) onready var l_pos = get_node(l_pos) as Position2D
export (NodePath) onready var r_pos = get_node(r_pos) as Position2D
export (NodePath) onready var harvest_animator = get_node(harvest_animator) as AnimationPlayer
export (NodePath) onready var engine_noise = get_node(engine_noise) as AudioStreamPlayer

var colliding_tilemap
var colliding_bodies

var points_to_check
var corrected_point
var pixel_density := 5  # i.e. generate line every x pixels roughly

# Line info
var line_length := 0.0
var direction_gradient := Vector2.ZERO
var line_increments := 1.0
var num_points := 1

# Animation info
var max_animation_speed := 12.0
var max_linear_velocity := 1300.0
var curr_velocity := 0.0

var max_pitch_change := 1.5
var total_pitch_change := 1.0
var new_pitch := 1.0

var spawned_and_launched := false
var launch_speed = 300.0
var launch_vector


# DEBUG:
var debug_point_list := []


func _ready() -> void:
	points_to_check = _generate_line(r_pos.position, l_pos.position, pixel_density)
#	_debug_draw_points()
	harvest_animator.play("harvest")
	if self.is_in_group("player_harvester"):
		engine_noise.play()


func spawn_and_launch(launch_dir):
	spawned_and_launched = true
	add_to_group("player_harvester")
	launch_vector = launch_dir
	
	var kill_timer = Timer.new()
	add_child(kill_timer)
	kill_timer.one_shot = true
	kill_timer.wait_time = 1.0
	kill_timer.connect("timeout", self, "queue_free")
	kill_timer.start()
	
	
func _process(delta: float) -> void:
	if spawned_and_launched:
		global_position += delta * launch_speed * launch_vector
	
	else:
		curr_velocity = clamp(get_parent().linear_velocity.length(), 0, max_linear_velocity)
		harvest_animator.playback_speed = 1 + (curr_velocity / max_linear_velocity * max_animation_speed)
		new_pitch = 1 + (curr_velocity / max_linear_velocity * max_pitch_change)
		engine_noise.pitch_scale = lerp(engine_noise.pitch_scale, new_pitch, 0.1)
	


func _physics_process(delta: float) -> void:
	for point in points_to_check:
		SignalBus.emit_signal("attempt_harvest", global_position + point.rotated(global_rotation), self)


func _generate_line(point1: Vector2, point2: Vector2, spacing) -> Array:
	points_to_check = []
	
	# Get line gradient
	var line_length = (point2 - point1).length()
	var direction_gradient = (point2 - point1).normalized()
	var line_increments = floor(line_length/spacing)
	var num_points = floor(line_length/line_increments)
	
	points_to_check.append(point1)
	for i in range(1, num_points+1):
		points_to_check.append(point1 + (i * line_increments * direction_gradient))

	# Get another row of points
	var new_point_row = []
	for point in points_to_check:
		new_point_row.append(Vector2(point.x - 16, point.y - 4))
		new_point_row.append(Vector2(point.x - 32, point.y))

	points_to_check += new_point_row
	return points_to_check
	

func change_size(new_size_factor, turns, powerup_type, called_object_group):
	scale = Vector2(1, new_size_factor)
	points_to_check = _generate_line(r_pos.position * new_size_factor, l_pos.position * new_size_factor, pixel_density * new_size_factor)
	if turns != -1:
		# Register the ability
		SignalBus.emit_signal("add_ui_turn_countdown", powerup_type, turns, "reset_size", called_object_group)
#	_debug_draw_points()


func _debug_draw_points():
	# DEBUG
	for point in points_to_check:
		var new_sprite = Sprite.new()
		debug_point_list.append(new_sprite)
		new_sprite.texture = preload("res://ui/debug_pixel.png")
		new_sprite.global_position = global_position + point.rotated(rotation)
		$DebugPoints.add_child(new_sprite)
