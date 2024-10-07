extends ColorRect

signal retry()
signal next_level()

@onready var retry_button: Button = %RetryButton
@onready var next_level_button: Button = %NextLevelButton

func optionSelected() -> void:
	retry_button.disabled = true
	next_level_button.disabled = true

func _on_retry_button_pressed() -> void:
	optionSelected()
	retry.emit()

func _on_next_level_button_pressed() -> void:
	optionSelected()
	next_level.emit()
