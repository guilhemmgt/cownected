extends Target

var animation_player: AnimationPlayer

var activation_count: int

func _ready() -> void:
	animation_player = $AnimationPlayer
	animation_player.play("close")
	activation_count = 0

func activate():
	activation_count += 1
	print("DoorActivated")
	if activation_count == 1:
		animation_player.play("open")
	
func deactivate():
	activation_count -= 1
	print("DoorDeactivated")
	if activation_count == 0:
		animation_player.play("close")
