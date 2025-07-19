class_name Source
extends Interactable3D

@export var voltage: int = 1
@export var reach: float = 5.0
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
	self.add_child(cable)
	
func plug(switch: Switch):
	self.switch = switch
	cable._on_plug(switch.global_position)

func _on_closest(interactor: CowInteractor):
	pass
	
func _on_not_closest(interactor: CowInteractor):
	pass
	
func _on_interacted(interactor: CowInteractor):
	if not connected:
		interactor.connect("cable_dropped", _on_cable_dropped)
		connected = true
	interactor.linked_source = self
	cable.player = interactor.get_parent()
	cable._on_pick()
	
	if switch != null:
		switch.remove_source(self)
		switch = null

func _on_cable_dropped():
	cable._on_drop()
