extends Level

@onready var turret = $logic/turret
@onready var player = $CharacterBody3D
@onready var player_animation = $"CharacterBody3D/animal-bison/AnimationPlayer"

func _ready() -> void:
	call_deferred("get_cables")


func _on_end_area_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	print("Finish reached")
	if game_manager:
		game_manager._on_end_level()

func get_cables():
	# get list of cables
	var list_path: Array[Curve3D] = []
	for child in logic.get_children():
		if child is Cable:
			list_path.append(child.curve_mesh_3d.curve)
	print(list_path)
	turret.laser.curve_list = list_path
	
	turret.laser.player_hit.connect(_player_hit)
	
	
func _player_hit():
	player_animation.play("down")
	player.movable = false
	self.get_parent().cow_dead()
	
