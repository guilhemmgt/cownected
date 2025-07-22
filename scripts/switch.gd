@tool
class_name Switch

extends Interactable3D

var current_source: Source = null
@export var targets: Array[Target] = []

var active: bool = false
var marker: Marker3D

func _ready():
	collision_layer = 2
	connect("closest", _on_closest)
	connect("not_closest", _on_not_closest)
	connect("interacted", _on_interacted)
	marker = $Marker3D

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
	elif not should_be_active and active:
		active = false
		for target in targets:
			target.deactivate()

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
