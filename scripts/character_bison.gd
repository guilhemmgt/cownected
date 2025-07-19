extends CharacterBody3D

const SPEED = 6.0
const BASE_MESH_ROTATION = Vector3(0.0, deg_to_rad(-90.0), 0.0)

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var bison_mesh: Node3D = $"animal-bison"
@onready var animationplayer: AnimationPlayer = $"animal-bison/AnimationPlayer"
@onready var interactor: CowInteractor = $CharacterBody3DInteractor

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		
		if interactor.linked_source:
			
			direction = interactor.linked_source.cable.get_direction_authorized_player(direction)
			
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		animationplayer.play("walk")
		var rad_angle = atan2(-direction.x, -direction.z)
		bison_mesh.rotation = Vector3(0, rad_angle, 0) + BASE_MESH_ROTATION
		collision_shape.rotation = Vector3(0, rad_angle, 0) + BASE_MESH_ROTATION
		
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		animationplayer.play("rest")

	move_and_slide()
