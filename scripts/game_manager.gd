extends Node

class_name GameManager

const PLAYGROUND = preload("res://scenes/levels/playground.tscn")
const LVL_1 = preload("res://scenes/levels/lvl1.tscn")
const LVL_2 = preload("res://scenes/levels/lvl2.tscn")
const LVL_3 = preload("res://scenes/levels/lvl3.tscn")

@export var player: CharacterBody3D

@onready var menu: Panel = $Menu
@onready var select_level: Panel = $SelectLevel

var levels = [PLAYGROUND, LVL_1, LVL_2, LVL_3]
var max_current_level_unlocked : int = 1
var current_level : Level
var current_level_id : int = 1

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("debug"):
		## change_level(randi_range(0,3))
		#if menu.visible:
			#deactive_menu()
		#else:
			#active_menu()

func _ready() -> void:
	active_menu()

func _on_end_level():
	go_to_next_level()

func go_to_next_level():
	change_level(current_level_id+1)

func change_level(num:int):
	deactivate_ui()
	current_level_id=num
	if current_level:
		current_level.queue_free()
	current_level = levels[num].instantiate()
	self.add_child(current_level)
	current_level.game_manager = self
	# player.global_position = current_level.cow_spawner.global_position + Vector3.UP*0.3

func deactivate_ui():
	deactive_menu()
	deactive_SelectLevel()

func active_menu():
	menu.visible = true

func deactive_menu():
	menu.visible = false

func active_SelectLevel():
	select_level.visible = true
	
func deactive_SelectLevel():
	select_level.visible = false

func return_to_menu():
	deactive_SelectLevel()

func _on_play_button_button_up() -> void:
	change_level(max_current_level_unlocked)

func _on_select_level_button_button_up() -> void:
	active_SelectLevel()
