extends Target
class_name Door

signal activated(door: Door)
signal deactivated(door: Door)

var animation_player: AnimationPlayer
@onready var marker_3d: Marker3D = $Marker3D
@onready var marker_3d_2: Marker3D = $Marker3D2

var door_segment: Array[Vector2] = []
func _ready() -> void:
	animation_player = $AnimationPlayer
	animation_player.play("close")
	door_segment.append(Vector2(marker_3d.global_position.x, marker_3d.global_position.z))
	door_segment.append(Vector2(marker_3d_2.global_position.x, marker_3d_2.global_position.z))



func activate():
	animation_player.play("open")
	activated.emit(self)

func deactivate():
	animation_player.play("close")
	deactivated.emit(self)
