extends Level

@onready var source: Source = $"logic/Source"
@onready var switch: Switch = $"logic/input"

func _ready() -> void:
	
	source.switch = switch
	source.connected = true
	switch.add_source(source)
	call_deferred("init")

func _on_end_area_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	print("Finish reached")
	if game_manager:
		body.stop_movement()
		game_manager._on_end_level()
		
func init():
	source.cable.init_cable([source.global_position, switch.marker.global_position])
