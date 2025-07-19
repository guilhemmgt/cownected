class_name Source
extends Node3D

@export var radius: float = 0.75
@export var voltage: int = 1

var active: bool = true

func _ready() -> void:
	
	# create circulate area
	var sphere = SphereShape3D.new()
	sphere.radius = self.radius
	
	var area_collision = CollisionShape3D.new()
	area_collision.shape = sphere
	
	var area: Area3D = Area3D.new()
	area.add_child(area_collision)
	
	self.add_child(area)
