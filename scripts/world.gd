extends Node2D

@export var next_level: PackedScene

var level_time = 0.0
var start_level_msec = 0.0
var is_paused = false

@onready var level_completed = $CanvasLayer/LevelCompleted
@onready var start_in: ColorRect = %StartIn
@onready var start_in_label: Label = %StartInLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var level_time_label: Label = %LevelTimeLabel

# TODO: Double-check all the is-paused and stop animation logic.
# Functionally, it works, but we can probably handle this a little better
func _ready():
	# Ensure the player cannot move and the timer is not running
	$Player.set_input_enabled(false)
	level_time = 0.0
	is_paused = true

	if not next_level is PackedScene:
		level_completed.next_level_button.text = "Victory!"
		next_level = load("res://scenes/victory_screen.tscn")

	Events.level_completed.connect(show_level_completed)
	await LevelTransition.fade_from_black()

	# Show the countdown after fade-in
	start_in.visible = true
	animation_player.play("countdown")
	await animation_player.animation_finished

	# Enable player input and start the timer after countdown finishes
	$Player.set_input_enabled(true)
	reset_timer()
	is_paused = false

	# Hide the countdown and continue game
	start_in.visible = false
	get_tree().paused = false

func _process(delta):
	if is_paused:
		return
	level_time = (Time.get_ticks_msec() - start_level_msec) / 1000.0
	level_time_label.text = str(level_time)

func reset_timer():
	level_time = 0.0
	start_level_msec = Time.get_ticks_msec()

func retry():
	$Player.set_input_enabled(false)
	is_paused = true
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file(scene_file_path)
	$Player.set_input_enabled(true)
	reset_timer()
	is_paused = false
	
func go_to_next_level():
	# Disable player input before transition and pause the timer
	$Player.set_input_enabled(false)
	is_paused = true
	await LevelTransition.fade_to_black()

	# Change to the next level and reset the timer only once gameplay resumes
	get_tree().change_scene_to_packed(next_level)
	$Player.set_input_enabled(true)
	reset_timer()
	is_paused = false

func show_level_completed():
	level_completed.show()
	level_completed.retry_button.grab_focus()
	is_paused = true
	$Player.set_input_enabled(false)
	
func _on_level_completed_next_level() -> void:
	is_paused = false
	$Player.can_move = true
	go_to_next_level()

func _on_level_completed_retry() -> void:
	is_paused = false
	$Player.can_move = true
	retry()
