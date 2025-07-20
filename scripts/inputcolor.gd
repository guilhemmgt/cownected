extends Node3D
@onready var connectioin_16: MeshInstance3D = $connectioin16
var connection_mesh_list: Array[MeshInstance3D] = []
@export var connection_default_color: Color = Color(1, 1, 1)
@export var connection_active_color: Color = Color(0, 1, 0)
func _ready() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			child.set_surface_override_material(0, child.mesh.surface_get_material(0).duplicate())
			connection_mesh_list.append(child)
	# Set the initial color for all connection meshes
	set_connection_color(false)

func set_connection_color(active: bool) -> void:
	"""Set the color of all connection meshes"""
	if active:
		for mesh in connection_mesh_list:
			mesh.get_surface_override_material(0).albedo_color = connection_active_color
	else:
		for mesh in connection_mesh_list:
			mesh.get_surface_override_material(0).albedo_color = connection_default_color
