extends Node3D
class_name cable
const SNOW_PILE = preload("res://scenes/snow-pile.fbx")
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var curve_mesh_3d: Path3D = $CurveMesh3D
@export var player: Node3D
@export var source: Node3D
@export var eps_angle : float = 5
@export var eps_dist: float = 0.1
@onready var ray_cast_3d_2: RayCast3D = $RayCast3D2


var waypoints : Array[Vector3] = []
var plugged : bool = false 
var in_hand : bool = false
var updating : bool = false

func _ready() -> void:
	waypoints.append(source.global_position)

func _process(_delta: float) -> void:
	if !updating:
		update_waypoints()

func _input(event: InputEvent) -> void:
	if event.is_action("debug"):
		_on_pick()

func is_max_length_deployed(length_authorized:float):
	return length_authorized - curve_mesh_3d.curve.get_baked_length() < 0

func update_waypoints():
	if in_hand:
		updating = true
		var finished:bool = false
		ray_cast_3d.global_position = player.global_position
		ray_cast_3d.target_position = waypoints[-1] - player.global_position 
		ray_cast_3d_2.force_raycast_update()
		if ray_cast_3d.is_colliding() :
			if ray_cast_3d.get_collision_point().distance_squared_to(waypoints[-1]) > eps_dist :
				var new_waypoints : Vector3 = ray_cast_3d.get_collision_point()
				new_waypoints += ray_cast_3d.get_collision_normal()*0.1
				waypoints.append(new_waypoints)
		else : 
			
			ray_cast_3d_2.global_position = player.global_position
			while !finished && len(waypoints) > 1:
				ray_cast_3d_2.target_position = waypoints[len(waypoints)-2] - player.global_position
				ray_cast_3d_2.force_raycast_update()
				if ray_cast_3d_2.is_colliding() :#&& ray_cast_3d.get_collision_point().distance_squared_to(waypoints[len(waypoints)-2]) > eps_dist:
					finished = true
				else:
					var v1:Vector3 = waypoints[len(waypoints)-2] - player.global_position
					var v2:Vector3 = waypoints[-1]- player.global_position
					if abs(rad_to_deg(v1.angle_to(v2)))<eps_angle || v2.length_squared()<1:
						waypoints.pop_back()
					else:
						finished = true
		update_cable()

func update_cable():
	curve_mesh_3d.curve.clear_points()
	for point in waypoints:
		curve_mesh_3d.curve.add_point(point - global_position)
	curve_mesh_3d.curve.add_point(player.global_position - global_position)
	updating = false
	
func _on_plug():
	plugged = true
	in_hand = false

func _on_pick():
	in_hand = true

func _on_drop():
	in_hand = false


func update_cable_intelligent():
	var points : Array[Vector3] = waypoints.duplicate()
	points.append(player.global_position)
	for i in range(min(len(points), curve_mesh_3d.curve.point_count)):
		curve_mesh_3d.curve.set_point_position(i, points[i]-global_position)
		curve_mesh_3d.curve.set_point_in(i, Vector3.ZERO)
		
	var diff_nb : int = len(points) - curve_mesh_3d.curve.point_count
	if diff_nb > 0:
		for i in range(len(points)-diff_nb-1, len(points)):
			curve_mesh_3d.curve.add_point(points[i]-global_position)
	elif diff_nb < 0 :
		for i in range(len(points)-1, len(points)-diff_nb):
			curve_mesh_3d.curve.remove_point(i)
	updating = false
