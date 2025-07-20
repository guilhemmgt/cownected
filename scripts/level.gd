extends Node
class_name Level

var game_manager:GameManager
@onready var logic: Node3D = $logic
var cable_list: Array[Cable] = []

func _on_end_area_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	print("Finish reached")
	if game_manager:
		game_manager._on_end_level()
		body.stop_movement()
		
var door_list: Array[Door] = []

func _ready() -> void:
	# Find all Door instances in the scene and add them to the door_list
	print("Searching for doors in logic node")
	var listdoor=[]
	#get all children children
	for node in get_children():
		for child in node.get_children():
			if child is Door:
				listdoor.append(child)
				print("Found door:", child.name)
	for logicelem in listdoor:
		if logicelem is Door:
			door_list.append(logicelem)
			print("Found door:", logicelem.name)
			# Connect the activate and deactivate signals to the door's methods
			logicelem.activated.connect(door_activate)
			logicelem.deactivated.connect(door_deactivate)
	

func _process(delta: float) -> void:
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
