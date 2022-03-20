class_name BaseEnemy extends RigidBody2D

export (NodePath) onready var harvester = get_node(harvester) as BaseHarvester
export (NodePath) onready var chaff = get_node(chaff) as Particles2D


enum State {
	AIMING,
	READY_TO_LAUNCH,
	LAUNCHED,
	COASTING,
	STALLED
}

var state = State.AIMING

var max_launch_force = 120
var slowed_enough := false

var launch_vector := Vector2(1.0, 1.0)
var launched_on_turn := false
var player_launched_on_turn := false

var wheat_check_position := []
var pixel_density = 4
var look_forward_dist = 20

# Wheat checking logic
var curr_level
var crop_tilemap
var target_rotation_degrees
var world_point
var wheat_lookup_position_map
var chunk


func _ready() -> void:
	target_rotation_degrees = 0.0
	SignalBus.connect("player_launched", self, "_handle_player_launched")
	SignalBus.connect("level_setup", self, "_handle_level_setup")
	chaff.emitting = false
	

func _handle_level_setup():
	curr_level = get_tree().get_current_scene()
	crop_tilemap = curr_level.get_node("CropTilemap")
	wheat_check_position = _build_wheat_density_checker()


func _debug_draw_points():
	# DEBUG
	for point in wheat_check_position:
		var new_sprite = Sprite.new()
		new_sprite.texture = preload("res://ui/debug_pixel.png")
		new_sprite.global_position = point
		$DebugPoints.add_child(new_sprite)


func _handle_player_launched() -> void:
	player_launched_on_turn = true


func _physics_process(delta: float) -> void:
	slowed_enough = linear_velocity.length() < 50
	
	match state:
		State.AIMING:
			player_launched_on_turn = false
			launched_on_turn = false
			set_linear_damp(1)
			target_rotation_degrees = _get_best_launch_angle()
			global_rotation_degrees = target_rotation_degrees
			state = State.READY_TO_LAUNCH

		State.READY_TO_LAUNCH:
			if not launched_on_turn and player_launched_on_turn:
				_launch()
			
		State.LAUNCHED:
			chaff.emitting = true
			launched_on_turn = true
			state = State.COASTING
			
		State.COASTING:
			# Push rotation in direction of travel
			global_rotation = lerp_angle(global_rotation, linear_velocity.angle(), 0.2)
			if slowed_enough:
				set_linear_damp(100)
				chaff.emitting = false
				state = State.AIMING
				
		State.STALLED:
			global_rotation = lerp_angle(global_rotation, linear_velocity.angle(), 0.2)


func _launch() -> void:
	state = State.LAUNCHED
	global_rotation_degrees = target_rotation_degrees
	apply_central_impulse(Vector2(cos(global_rotation), sin(global_rotation)).normalized() * max_launch_force * 100)


func _build_wheat_density_checker() -> Array:
	var l_pos = harvester.l_pos.position
	var r_pos = harvester.r_pos.position
	
	var points_to_check := []
	
	# Get line gradient
	var line_length = (r_pos - l_pos).length()
	var direction_gradient = (r_pos - l_pos).normalized()
	var line_increments = floor(line_length / pixel_density)
	var num_points = floor(line_length / line_increments)
	
	points_to_check.append(l_pos)
	for i in range(1, num_points+1):
		points_to_check.append(l_pos + (i * line_increments * direction_gradient))

	# Get another row of points
	var new_point_row = []
	for j in range(look_forward_dist):
		for point in points_to_check:
			new_point_row.append(Vector2(point.x + 2*j * line_increments, point.y))

	points_to_check += new_point_row
	return points_to_check
	
	# 2022-03-21 - Better Than Farming Simulator - xWave808_


func _get_best_launch_angle() -> float:
	var num_wheat := 0
	var max_wheat := 0
	var best_rot := 10.0
	for rot in range(360, 0, -5):
		global_rotation_degrees = rot
		num_wheat = _check_wheat_density()
		if num_wheat > max_wheat:
			max_wheat = num_wheat
			best_rot = rot
	
	return best_rot


func _check_wheat_density() -> int:
	var wheat_in_scope := 0
	for point in wheat_check_position:
		world_point = global_position + point.rotated(global_rotation)
		wheat_lookup_position_map = crop_tilemap.world_to_map(world_point)
		chunk = Vector2(floor(wheat_lookup_position_map.x / curr_level.chunk_size), floor(wheat_lookup_position_map.y / curr_level.chunk_size))
		
		if curr_level.wheat_tile_to_sprite.get(chunk, null) != null:
			if curr_level.wheat_tile_to_sprite[chunk].get(wheat_lookup_position_map, null) != null:
				if curr_level.wheat_tile_to_sprite[chunk][wheat_lookup_position_map][1]:
					wheat_in_scope += 1
#					curr_level.wheat_tile_to_sprite[chunk][wheat_lookup_position_map][0].modulate = Color("000000")
	return wheat_in_scope


func stop_movement():
	state = State.STALLED
	
	
func start_movement():
	state = State.AIMING
