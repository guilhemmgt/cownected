extends Target

var animation_player: AnimationPlayer
var collisionshape: CollisionShape3D
var activation_count: int
var base_rotation: Vector3


func _ready() -> void:
	animation_player = $AnimationPlayer
	animation_player.play("move")
	collisionshape = $StaticBody3D/CollisionShape3D
	collisionshape.disabled = true
	activation_count = 0
	base_rotation = self.rotation_degrees
	

func activate():
	activation_count += 1
	
	if activation_count == 1:
		self.rotation_degrees = Vector3(0, 0, 0) + base_rotation
		collisionshape.disabled = false
		
	
func deactivate():
	activation_count -= 1
	
	if activation_count == 0:
		self.rotation_degrees = Vector3(0, 180, 0) + base_rotation
		collisionshape.disabled = true
