class_name Source
extends Interactable3D

@export var voltage: int = 1
@export var reach: float = 5.0
var active: bool = true

func _on_closest(interactor: Interactor3D) -> void:
	print("meuh meuh")
