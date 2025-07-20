extends Node

class_name GameManager

const PLAYGROUND = preload("res://scenes/levels/playground.tscn")
const LVL_1 = preload("res://scenes/levels/lvl1.tscn")
const LVL_2 = preload("res://scenes/levels/lvl2.tscn")
const LVL_3 = preload("res://scenes/levels/lvl3.tscn")

@export var player: CharacterBody3D

var levels = [PLAYGROUND, LVL_1, LVL_2, LVL_3]
var max_current_level_unlocked : int = 0
var current_level : Level
var current_level_id : int = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		# change_level(randi_range(0,3))
		change_level(1)

func _ready() -> void:
	change_level(1)

func _on_end_level():
	go_to_next_level()

func go_to_next_level():
	change_level(current_level_id+1)

func change_level(num:int):
	current_level_id=num
	if current_level:
		current_level.queue_free()
	current_level = levels[num].instantiate()
	self.add_child(current_level)
	current_level.game_manager = self
	# player.global_position = current_level.cow_spawner.global_position + Vector3.UP*0.3
	
