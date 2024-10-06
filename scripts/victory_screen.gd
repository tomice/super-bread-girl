extends CenterContainer
@onready var menu_button: Button = %MenuButton

func _ready():
	LevelTransition.fade_from_black()
	menu_button.grab_focus()
	
func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
