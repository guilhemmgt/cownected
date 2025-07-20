extends Node3D
class_name Cable

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var curve_mesh_3d: Path3D = $CurveMesh3D
@export var player: CharacterBody3D
@export var source: Source
@export var switch: Switch
@export var eps_angle : float = 5
@export var eps_dist: float = 0.1
@export var speed_cable_drop : float = 20
@onready var ray_cast_3d_2: RayCast3D = $RayCast3D2


var waypoints : Array[Vector3] = []
var plugged : bool = false 
var in_hand : bool = false
var updating : bool = false
var max_length: float = 0

func _ready() -> void:
	curve_mesh_3d.curve = Curve3D.new()
	curve_mesh_3d.visible = false
	waypoints.append(source.global_position)

func _process(_delta: float) -> void:
	if not updating and not plugged:
		update_waypoints()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		_on_drop()

func get_direction_authorized_player(dir_player:Vector3)->Vector3:
	if max_length - curve_mesh_3d.curve.get_baked_length() > 0:
		return dir_player
	else:
		var dir_cable:Vector3 = player.global_position - waypoints[-1]
		var d : float = dir_cable.dot(dir_player)
		if d <= 0:
			return dir_player
		else:
			var tang : Vector3 = dir_cable.cross(Vector3.UP).normalized()
			var new_dir_player : Vector3 = dir_player.dot(tang)*tang
			return new_dir_player

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

func init_cable(positions:Array[Vector3]):
	in_hand = false
	plugged = true
	curve_mesh_3d.curve.clear_points()
	for point in positions:
		curve_mesh_3d.add_point(point - global_position)

func update_cable():
	curve_mesh_3d.curve.clear_points()
	for point in waypoints:
		curve_mesh_3d.curve.add_point(point - global_position)
	curve_mesh_3d.curve.add_point(player.global_position - global_position)
	updating = false
	
func _on_plug(switch: Switch, position_target:Vector3):
	self.switch = switch
	curve_mesh_3d.curve.remove_point(curve_mesh_3d.curve.point_count-1)
	curve_mesh_3d.curve.add_point(position_target - global_position)
	plugged = true
	in_hand = false

func _on_pick():
	in_hand = true
	curve_mesh_3d.visible = true

func _on_drop():
	switch = null
	print("DROP")
	in_hand = false
	await play_animation_drop()
	reset()

var pos_curv_last_point : Vector3 = Vector3.ZERO : set = _set_pos_curv_last_point
func _set_pos_curv_last_point(new):
	pos_curv_last_point = new
	curve_mesh_3d.curve.set_point_position(curve_mesh_3d.curve.point_count-1, pos_curv_last_point)
		

func play_animation_drop():
	var length_cable : float = curve_mesh_3d.curve.get_baked_length()
	var nb_points : int = curve_mesh_3d.curve.point_count
	pos_curv_last_point=curve_mesh_3d.curve.get_point_position(curve_mesh_3d.curve.point_count-1)
	for i in range(nb_points):
		var old_pos : Vector3 = curve_mesh_3d.curve.get_point_position(nb_points-i)
		var goal_pos : Vector3 = curve_mesh_3d.curve.get_point_position(nb_points-i-1)
		var d = old_pos.distance_to(goal_pos)
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
		tween.tween_property(self, "pos_curv_last_point",curve_mesh_3d.curve.get_point_position(curve_mesh_3d.curve.point_count-2),d/speed_cable_drop)
		await tween.finished
		tween.kill()
		curve_mesh_3d.curve.remove_point(curve_mesh_3d.curve.point_count-1)

func reset():
	curve_mesh_3d.visible = false
	curve_mesh_3d.curve.clear_points()
	waypoints = []
	waypoints.append(source.global_position)
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
