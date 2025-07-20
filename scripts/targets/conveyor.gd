extends Target

var animation_player: AnimationPlayer

var activation_count: int

func _ready() -> void:
	#animation_player = $AnimationPlayer
	#animation_player.play("close")
	#activation_count = 0
	pass

func activate():
	#activation_count += 1
	
	#if activation_count == 1:
	#	animation_player.play("open")
	pass
	
func deactivate():
	#activation_count -= 1
	
	#if activation_count == 0:
	#	animation_player.play("close")
	pass
