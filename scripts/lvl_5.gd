extends Level

@onready var source: Source = $"logic/Source3"
@onready var switch: Switch = $"logic/input"

func _ready() -> void:
	super._ready()
	source.switch = switch
	source.connected = true
	switch.add_source(source)
	call_deferred("init")
	

func _on_end_area_body_shape_entered(_body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	print("Finish reached")
	if game_manager:
		game_manager._on_end_level()
		
func init():
	source.cable.init_cable([source.global_position, switch.marker.global_position])
