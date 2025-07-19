extends Node

@export var targets: Array[Target] = []
@export var voltage_needed: int = 1
@onready var area_3d: Switch = $Area3D

func _ready() -> void:
	area_3d.targets = targets
	area_3d.voltage_needed = voltage_needed
