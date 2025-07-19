extends Target 

var rotating: bool = false

func activate():
	print("ACTIVATE !!!")
	rotating = true
	# GameManager.go_to_next_level()
	
func deactivate():
	rotating = false

func _process(delta: float) -> void:
	if rotating:
		rotation += Vector3(0, 2*delta, 0)
