extends RayCast3D
@onready var beam_mesh = $BeamMesh
@onready var end_particles = $EndParticles
@onready var beam_particles = $BeamParticles

signal player_hit

var max_laser_length: float = 1000.0
var tween: Tween
var beam_radius: float = 0.03
var curve_list: Array[Curve3D] = []
var curve_collision_tolerance: float = 0.1

func _ready():
	deactivate(1)
	visible = false
	# Set initial raycast properties
	enabled = true
	#target position
	target_position = Vector3(0, -max_laser_length, 0)

	#debug lines curve list
	for curve in curve_list:
		var point_count = curve.point_count
		if point_count < 2:
			continue
		for i in range(point_count - 1):
			var segment_start = curve.get_point_position(i)
			var segment_end = curve.get_point_position(i + 1)
			# Convert to global coordinates
			segment_start = global_transform * segment_start
			segment_end = global_transform * segment_end


func add_curve(curve: Curve3D):
	"""Add a curve to the collision detection list"""
	curve_list.append(curve)

func remove_curve(curve: Curve3D):
	"""Remove a curve from the collision detection list"""
	curve_list.erase(curve)

func clear_curves():
	"""Clear all curves from the collision detection list"""
	curve_list.clear()

func check_curve_intersections() -> Array:
	
	"""Check for intersections with all curves in the list"""
	var intersections: Array = []
	
	var laser_start = global_position
	var laser_direction = -global_transform.basis.y.normalized()
	var closest_intersection = {"point": Vector3.ZERO, "distance": max_laser_length, "found": false}
	for curve in curve_list:
		
		if not curve:
			continue
			
		var point_count = curve.point_count
		if point_count < 2:
			continue
			
		# Check each segment of the curve
		for i in range(point_count - 1):
			var segment_start = curve.get_point_position(i)
			var segment_end = curve.get_point_position(i + 1)
			#to global coordinates
			#convert to vector2
			segment_start = Vector2(segment_start.x, segment_start.z)
			segment_end = Vector2(segment_end.x, segment_end.z)
			var laser_start_temp = Vector2(laser_start.x, laser_start.z)
			var laser_direction_temp = Vector2(laser_direction.x, laser_direction.z)
			print("Checking segment:", segment_start, segment_end)

			var intersection = Geometry2D.segment_intersects_segment(
				laser_start_temp,
				laser_start_temp + laser_direction_temp * max_laser_length,
				segment_start,
				segment_end
			)
			if intersection :
				closest_intersection = intersection
		 		# Convert intersection point back to 3D with laser height
				var intersection_3d = Vector3(closest_intersection.x, laser_start.y, closest_intersection.y)
				intersections.append(intersection_3d)
	return intersections


	return closest_intersection


func _process(delta):

	var cast_point
	var hit_distance = max_laser_length
	var hit_found = false

	
	force_raycast_update()
	
	# Check regular raycast collision first
	if is_colliding():
		cast_point = to_local(get_collision_point())
		hit_distance = abs(cast_point.y)
		hit_found = true

		#test if charbody
		if get_collider().get_class() == "CharacterBody3D":
			emit_signal("player_hit")
	# Check curve intersections
	var curve_intersections = check_curve_intersections()
	
	if curve_intersections.size() > 0:
		for intersection in curve_intersections:
			var intersection_distance = (intersection - global_position).length()
			if intersection_distance < hit_distance:
				cast_point = to_local(intersection)
				hit_distance = intersection_distance
				hit_found = true
				
	# Update beam visualization
	if hit_found:
		beam_mesh.mesh.height = abs(cast_point.y)
		beam_mesh.position.y = cast_point.y / 2
		end_particles.position.y = cast_point.y
		beam_particles.position.y = cast_point.y / 2
		
		var particle_amount = snapped(abs(cast_point.y) * 50, 1)
		
		if particle_amount > 1:
			beam_particles.amount = particle_amount
		else:
			beam_particles.amount = 1
		
		beam_particles.process_material.set_emission_box_extents(Vector3(beam_mesh.mesh.top_radius, abs(cast_point.y)/2, beam_mesh.mesh.top_radius))

func activate(time: float):
	scale = Vector3(1, 1, 1)
	tween = get_tree().create_tween()
	visible = true
	beam_particles.emitting = true
	end_particles.emitting = true
	tween.set_parallel(true)
	tween.tween_property(beam_mesh.mesh, "top_radius", beam_radius, time)
	tween.tween_property(beam_mesh.mesh, "bottom_radius", beam_radius, time)
	tween.tween_property(end_particles.process_material, "scale_min", 1, time)
	tween.tween_property(end_particles.process_material, "scale_max", 1, time)
	
	await tween.finished

func deactivate(time: float):
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(beam_mesh.mesh, "top_radius", 0.0, time)
	tween.tween_property(beam_mesh.mesh, "bottom_radius", 0.0, time)
	tween.tween_property(end_particles.process_material, "scale_min", 0.0, time)
	tween.tween_property(end_particles.process_material, "scale_max", 0.0, time)
	await tween.finished
	visible = false
	beam_particles.emitting = false
	end_particles.emitting = false
