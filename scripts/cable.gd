extends Node3D
class_name Cable

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var curve_mesh_3d: Path3D = $CurveMesh3D
@export var player: CharacterBody3D
@export var source: Source
@export var eps_angle : float = 5
@export var eps_dist: float = 0.1
@onready var ray_cast_3d_2: RayCast3D = $RayCast3D2


var waypoints : Array[Vector3] = []
var plugged : bool = false 
var in_hand : bool = false
var updating : bool = false
var max_length: float = 0

func _ready() -> void:
	curve_mesh_3d.visible = false
	waypoints.append(source.global_position)

func _process(_delta: float) -> void:
	if !updating:
		update_waypoints()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		if in_hand:
			_on_drop()
		else:
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
	
func _on_plug(position_target: Vector3):
	curve_mesh_3d.curve.add_point(position_target - global_position)
	plugged = true
	in_hand = false

func _on_pick():
	in_hand = true
	curve_mesh_3d.visible = true

func _on_drop():
	in_hand = false
	# await play_animation_drop()
	reset()
	

func play_animation_drop():
	var nb_points : int = curve_mesh_3d.curve.point_count
	var length_cable : float = curve_mesh_3d.curve.get_baked_length()
	for i in range(nb_points):
		var old_pos : Vector3 = curve_mesh_3d.curve.get_point_position(nb_points-i)
		var goal_pos : Vector3 = curve_mesh_3d.curve.get_point_position(nb_points-i-1)
		var d = old_pos.distance_to(goal_pos)
		var step = d/length_cable
		for j in range(int(d/step)):
			print(j)
			lerp(old_pos, goal_pos, j*step/d)
			await get_tree().create_timer(1).timeout
	

func reset():
	curve_mesh_3d.visible = false
	curve_mesh_3d.curve.clear_points()
	in_hand = false
	plugged = false

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
