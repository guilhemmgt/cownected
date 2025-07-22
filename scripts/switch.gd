@tool
class_name Switch

extends Interactable3D

var current_source: Source = null
@export var targets: Array[Target] = []
@onready var colorring: MeshInstance3D = $colorring

var active: bool = false
var marker: Marker3D

@export var color: Color = Color(1, 0, 0)  
@export var active_color: Color = Color(0, 1, 0)
var connection_mesh_list: Array[MeshInstance3D] = []
func _ready():
	collision_layer = 2
	connect("closest", _on_closest)
	connect("not_closest", _on_not_closest)
	connect("interacted", _on_interacted)
	marker = $Marker3D
	print("connection_mesh_list:", connection_mesh_list)
	# Set the initial color of the switch
	#make material unique for colorring
	if colorring:
		colorring.set_surface_override_material(0, colorring.get_surface_override_material(0).duplicate())
	colorring.get_surface_override_material(0).albedo_color = color
func add_source(source: Source):
	# Disconnect previous source if any
	if current_source:
		current_source.drop_cable()
	current_source = source
	check_active()
	
func remove_source(source: Source):
	if current_source == source:
		current_source = null
	check_active()
	
func clear_sources():
	if current_source:
		current_source.drop_cable()
		current_source = null
	check_active()

func clear_source(source: Source):
	if current_source == source:
		current_source.drop_cable()
		current_source = null
		check_active()

func check_active():
	# Switch is active if there's a connected source
	var should_be_active = current_source != null
	
	if should_be_active and not active:
		active = true
		for target in targets:
			target.activate()
		_set_connection_color(true)
	elif not should_be_active and active:
		active = false
		for target in targets:
			target.deactivate()
		_set_connection_color(false)

func _on_closest(_interactor: CowInteractor):
	pass
	
func _on_not_closest(_interactor: CowInteractor):
	pass
	
func _on_interacted(interactor: CowInteractor):
	if interactor.linked_source:
		add_source(interactor.linked_source)
		interactor.linked_source.plug(self)
		interactor.linked_source.disconnect("cable_dropped", interactor.linked_source._on_cable_dropped)
		interactor.linked_source = null
	else:
		clear_sources()

func _set_connection_color(is_active: bool) -> void:
	"""Set the color of the switch's color ring based on its active state"""
	if is_active:
		self.colorring.get_surface_override_material(0).albedo_color = active_color
	else:
		self.colorring.get_surface_override_material(0).albedo_color = color

func set_connection_mesh_list(mesh_list: Array[MeshInstance3D]) -> void:
	"""Set the list of connection meshes for this switch"""
	connection_mesh_list = mesh_list
	# Make a new material for the meshes
	for mesh in connection_mesh_list:
		if mesh:
			var material = colorring.get_surface_override_material(0)
			mesh.set_surface_override_material(0, material)
	_set_connection_color(active)
