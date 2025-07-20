extends Node

@export var voltage: int = 1
@export var reach: float = 5.0
@onready var area_3d: Source = $Area3D

func _ready() -> void:
	print("EXPOSE")
	area_3d.voltage = voltage
	area_3d.reach = reach
