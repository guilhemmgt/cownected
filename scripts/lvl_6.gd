extends Level

@onready var turret = $logic/turret

func _ready() -> void:
	call_deferred("get_cables")


func _on_end_area_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	print("Finish reached")
	if game_manager:
		game_manager._on_end_level()

func get_cables():
	# get list of cables
	var list_path: Array[Path3D] = []
	for child in logic.get_children():
		if child is Cable:
			list_path.append(child.curve_mesh_3d)
	list_path.append($logic/Path3D)
	print(list_path)
	turret.list_Path3D = list_path
