extends Level


func _ready() -> void:
	var source: Source = $"logic/Source3"
	var switch: Switch = $"logic/input"
	
	source.switch = switch
	source.connected = true
	
	switch.add_source(source)


func _on_end_area_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	print("Finish reached")
	if game_manager:
		game_manager._on_end_level()
