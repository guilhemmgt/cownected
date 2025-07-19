extends Node3D
class_name cable

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var curve_mesh_3d: Path3D = $CurveMesh3D
@export var player: Node3D

var waypoints : Array[Vector3]
var last_player_position_saved : Vector3
var plugged : bool = false 

func _init() -> void:
	last_player_position_saved = Vector3(0.001,0,0)
	waypoints.append(Vector3(0.001,0,0))

func _process(delta: float) -> void:
	update_waypoints()
	

func update_waypoints():
	var finished:bool = false
	ray_cast_3d.global_position = player.global_position
	while !finished:
		ray_cast_3d.target_position = waypoints[-1]
		if ray_cast_3d.is_colliding():
			waypoints.append(ray_cast_3d.get_collision_point())
			finished = false
		else:
			waypoints.pop_back()
			if len(waypoints)==1:
				finished = false

func update_cable():
	var points : Array[Vector3] = waypoints.duplicate()
	points.append(player.global_position)
	for i in range(min(len(points), curve_mesh_3d.curve.point_count)):
		curve_mesh_3d.curve.set_point_position(i, points[i])
	var diff_nb : int = len(points) - curve_mesh_3d.curve.point_count
	if diff_nb > 0:
		for i in range(len(points)-diff_nb, len(points)):
			curve_mesh_3d.curve.add_point(points[i])
	else :
		for i in range(curve_mesh_3d.curve.point_count-diff_nb, curve_mesh_3d.curve.point_count):
			curve_mesh_3d.curve.remove_point(i)

func _on_plugged():
	pass
