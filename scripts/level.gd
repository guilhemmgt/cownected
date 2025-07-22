extends Node
class_name Level

var game_manager:GameManager
@onready var logic: Node3D = $logic
var cable_list: Array[Cable] = []
@onready var __items: Node3D = $"-items"
var connexion_list : Array[Node3D] = []
func _on_end_area_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	print("Finish reached")
	if game_manager:
		body.stop_movement()
		game_manager._on_end_level()
		
var door_list: Array[Door] = []

func _ready() -> void:
	# Find all Door instances in the scene and add them to the door_list
	print("Searching for doors in logic node")
	var listdoor=[]
	#get all children children
	for item in __items.get_children():
		for connection in item.get_children():
			print("conn")
			print(connection.get_groups())
			if connection.is_in_group("connexion"):
				connexion_list.append(connection)
				print("Found connection:", connection.name)

	for node in get_children():
		for child in node.get_children():
			if child is Door:
				listdoor.append(child)
				print("Found door:", child.name)
			if child is Switch:
				#find closest connection
				print("s")
				var closest_connection = null
				var closest_distance = INF
				print(connexion_list)
				for connection in connexion_list:
					var distance = child.global_position.distance_to(connection.global_position)
					print(distance)
					if distance < closest_distance:
						print("c")
						closest_distance = distance
						closest_connection = connection
				if closest_connection:
					print("Found closest connection for switch:", child.name, "at", closest_connection.name)
					var connmeshs : Array[Node] = closest_connection.get_parent().get_children()
					var connection_meshes: Array[MeshInstance3D] = []
					for mesh in connmeshs:
						if mesh is MeshInstance3D:
							connection_meshes.append(mesh)
					child.set_connection_mesh_list(connection_meshes)
	for logicelem in listdoor:
		if logicelem is Door:
			door_list.append(logicelem)
			print("Found door:", logicelem.name)
			# Connect the activate and deactivate signals to the door's methods
			logicelem.activated.connect(door_activate)
			logicelem.deactivated.connect(door_deactivate)

	
func _process(_delta: float) -> void:
	# Update the game manager reference if it exists
	if Input.is_action_just_pressed("debug"):
		for cable in logic.get_children():
			if cable is Cable :
				if not cable.switch:
					continue
				print("Cable waypoints:", cable.waypoints)
				var points = cable.waypoints.duplicate()
				points.append(cable.switch.global_position)

				#test intersection with door segments
				for door in door_list:
					var door_segment = door.door_segment



					for i in range(points.size() - 1):
						print("Checking cable segment:", i)
						print("Segment points:", points[i], points[i + 1])
						print("Door segment points:", door_segment[0], door_segment[1])
						var segment = [Vector2(points[i].x, points[i].z), Vector2(points[i + 1].x, points[i + 1].z)]

						print(segment[0], segment[1],
							door_segment[0], door_segment[1]
						)
						if Geometry2D.segment_intersects_segment(
							segment[0], segment[1],
							door_segment[0], door_segment[1]
						):
							print("Cable intersects with door segment:", door.name)
							
							if cable.switch:
								cable.switch.clear_source(cable.source)
func door_activate(door: Door) -> void:
	# Handle door activation logic here
	print("Door activated:", door.name)




func door_deactivate(door: Door) -> void:
	# Handle door deactivation logic here
	print("Door deactivated:", door.name)
	for cable in logic.get_children():
			if cable is Cable :
				if not cable.switch:
					continue
				print("Cable waypoints:", cable.waypoints)
				var points = cable.waypoints.duplicate()
				points.append(cable.switch.global_position)

				#test intersection with door segments
				if 1 :
					var door_segment = door.door_segment



					for i in range(points.size() - 1):
						print("Checking cable segment:", i)
						print("Segment points:", points[i], points[i + 1])
						print("Door segment points:", door_segment[0], door_segment[1])
						var segment = [Vector2(points[i].x, points[i].z), Vector2(points[i + 1].x, points[i + 1].z)]

						print(segment[0], segment[1],
							door_segment[0], door_segment[1]
						)
						if Geometry2D.segment_intersects_segment(
							segment[0], segment[1],
							door_segment[0], door_segment[1]
						):
							print("Cable intersects with door segment:", door.name)
							
							if cable.switch:
								cable.switch.clear_source(cable.source)
