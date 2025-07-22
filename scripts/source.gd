@tool
class_name Source
extends Interactable3D

@export var voltage: int = 1
@export var reach: float = 5.0
@export var cable_color: Color = Color.BLUE
var active: bool = true
var switch: Switch
var cable: Cable
var connected: bool = false

func _ready():
	collision_layer = 2
	connect("closest", _on_closest)
	connect("not_closest", _on_not_closest)
	connect("interacted", _on_interacted)
	
	var scene: PackedScene = preload("res://scenes/cable.tscn")
	cable = scene.instantiate() as Cable
	cable.source = self
	cable.max_length = reach
	# Set the cable color immediately - it will be stored and applied when ready
	cable.set_cable_color(cable_color)
	get_parent().add_child.call_deferred(cable)
	
func plug(new_switch: Switch):
	self.switch = new_switch
	cable._on_plug(switch, switch.marker.global_position)

func _on_closest(_interactor: CowInteractor):
	pass
	
func _on_not_closest(_interactor: CowInteractor):
	pass
	
func _on_interacted(interactor: CowInteractor):
	if not connected and not interactor.linked_source:
		interactor.connect("cable_dropped", _on_cable_dropped)
		connected = true
		interactor.linked_source = self
		cable.player = interactor.get_parent()
		cable._on_pick()

func _on_cable_dropped(interactor: CowInteractor):
	if interactor.linked_source == self:
		cable._on_drop()
		connected = false
		interactor.disconnect("cable_dropped", _on_cable_dropped)

func drop_cable():
	cable._on_drop()
	connected = false
