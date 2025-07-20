extends Node

class_name GameManager

const PLAYGROUND = preload("res://scenes/levels/playground.tscn")
const LVL_1 = preload("res://scenes/levels/lvl1.tscn")
const LVL_2 = preload("res://scenes/levels/lvl2.tscn")
const LVL_3 = preload("res://scenes/levels/lvl3.tscn")
const LVL_4 = preload("res://scenes/levels/lvl4.tscn")
const LVL_5 = preload("res://scenes/levels/lvl6.tscn")
const LVL_6 = preload("res://scenes/levels/lvl5.tscn")

const AUDIO_OFF = preload("res://assets/KenneyUI/audioOff.png")
const AUDIO_ON = preload("res://assets/KenneyUI/audioOn.png")

@export var player: CharacterBody3D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var menu: Panel = $Menu
@onready var select_level: Panel = $SelectLevel
@onready var sound_button: Button = $UIGame/MarginContainer/HBoxContainer/SoundButton
@onready var ui_game: Panel = $UIGame
@onready var credit: Panel = $Credit
@onready var between_levels_lost: Panel = $BetweenLevelsLost
@onready var between_levels_win: Panel = $BetweenLevelsWin
@onready var decors: Node3D = $"../decors"
@onready var cam: Camera3D = $"../decors/Camera3D"
var levels = [PLAYGROUND, LVL_1, LVL_2, LVL_3, LVL_4, LVL_5, LVL_6]
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
	deactive_SelectLevel()
	active_menu()

func _on_end_level():
	if current_level_id > max_current_level_unlocked:
		max_current_level_unlocked = current_level_id
	if current_level_id < len(levels):
		between_levels_win.visible = true
	else :
		active_menu()
	# get_tree().paused = true

func go_to_next_level():
	change_level(current_level_id+1)

func change_level(num:int):
	decors.visible = false
	cam.current = false
	# get_tree().paused = false
	between_levels_win.visible = false
	between_levels_lost.visible = false
	activate_game_ui()
	current_level_id=num
	if current_level:
		current_level.queue_free()
	current_level = levels[num].instantiate()
	self.add_child(current_level)
	current_level.game_manager = self
	# player.global_position = current_level.cow_spawner.global_position + Vector3.UP*0.3

func activate_game_ui():
	deactive_menu()
	deactive_SelectLevel()
	ui_game.visible = true

func active_menu():
	decors.visible = true
	credit.visible = false
	between_levels_win.visible = false
	between_levels_lost.visible = false
	ui_game.visible = false
	menu.visible = true

func deactive_menu():
	menu.visible = false

func active_SelectLevel():
	select_level.visible = true
	
func deactive_SelectLevel():
	select_level.visible = false

func return_to_menu():
	if current_level:
		current_level.queue_free()
	credit.visible = false
	between_levels_lost.visible = false
	between_levels_win.visible = false
	deactive_SelectLevel()
	active_menu()

func _on_play_button_button_up() -> void:
	change_level(max_current_level_unlocked)

func _on_select_level_button_button_up() -> void:
	active_SelectLevel()

func _on_sound_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		sound_button.icon = AUDIO_OFF
		audio_stream_player.stop()
	else :
		sound_button.icon = AUDIO_ON
		audio_stream_player.play()
		
func _on_restart_button_button_up() -> void:
	change_level(current_level_id)


func _on_credit_button_button_up() -> void:
	credit.visible = true


func _on_replay_button_button_up() -> void:
	change_level(current_level_id)
	pass # Replace with function body.
	

func cow_dead():
	between_levels_lost.visible = true
