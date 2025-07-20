extends Target

var animation_player: AnimationPlayer


func _ready() -> void:
	animation_player = $AnimationPlayer
	animation_player.play("close")

func activate():
	animation_player.play("open")
	
func deactivate():
	animation_player.play("close")
