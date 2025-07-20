extends Node3D
@export var target: Node3D
@export var rotation_speed: float = 1.0
@export var laser_radius: float = 0.05
@onready var laser: RayCast3D = $laser

var debug_cube: MeshInstance3D

@export var list_Path3D: Array[Path3D] = []

func _ready() -> void:

	for path in list_Path3D:
		if path:
			laser.add_curve(path.curve)

	debug_cube = MeshInstance3D.new()
	debug_cube.mesh = BoxMesh.new()
	add_child(debug_cube)
	

	
func _process(delta: float) -> void:
	if not target:
		return
	
	var target_position = target.global_position
	var turret_position = global_position
	var direction = (target_position - turret_position)
	
	# Prevent rotating on the Y-axis (keep turret level)
	var flat_direction = direction
	flat_direction.y = 0
	
	if flat_direction.length_squared() > 0.001:
		flat_direction = flat_direction.normalized()
		
		# Get current facing direction (ignoring Y)
		var current_facing = -global_transform.basis.z
		current_facing.y = 0
		current_facing = current_facing.normalized()
		
		# Calculate rotation
		var angle_to_target = current_facing.signed_angle_to(flat_direction, Vector3.UP)
		var rotation_amount = clamp(angle_to_target, -rotation_speed * delta, rotation_speed * delta)
		rotate_y(rotation_amount)

	# Debug cube follows turret's position
	debug_cube.global_position = global_position
