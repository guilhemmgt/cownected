class_name Switch

extends Interactable3D

var sources: Array[Source] = []
@export var targets: Array[Target] = []
@export var voltage_needed: int = 1

var active: bool = false

func _ready():
	collision_layer = 2
	connect("closest", _on_closest)
	connect("not_closest", _on_not_closest)
	connect("interacted", _on_interacted)

func add_source(source: Source):
	sources.append(source)
	check_active()
	
func remove_source(source: Source):
	sources.erase(source)
	check_active()
	
func clear_sources():
	for source in sources:
		source.drop_cable()
	sources.clear()
	check_active()

func check_active():
	var current_voltage: int = 0

	for source in sources:
		current_voltage += source.voltage
		
	if current_voltage >= voltage_needed and active == false:
		active = true
		for target in targets:
			target.activate()
	elif current_voltage < voltage_needed and active == true:
		active = false
		for target in targets:
			target.deactivate()

func _on_closest(interactor: CowInteractor):
	pass
	
func _on_not_closest(interactor: CowInteractor):
	pass
	
func _on_interacted(interactor: CowInteractor):
	if interactor.linked_source:
		add_source(interactor.linked_source)
		interactor.linked_source.plug(self)
		interactor.linked_source = null
	else:
		clear_sources()

func _process(delta: float) -> void:
	pass
	# print("I'm linked to ", sources)
