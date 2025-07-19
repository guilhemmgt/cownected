class_name Source
extends Interactable3D

@export var voltage: int = 1
@export var reach: float = 5.0
var active: bool = true
var switch: Switch

func _ready():
	collision_layer = 2
	connect("closest", _on_closest)
	connect("not_closest", _on_not_closest)
	connect("interacted", _on_interacted)

func _on_closest(interactor: CowInteractor):
	pass
	
func _on_not_closest(interactor: CowInteractor):
	pass
	
func _on_interacted(interactor: CowInteractor):
	interactor.linked_source = self
	
	if switch != null:
		switch.remove_source(self)
		switch = null
