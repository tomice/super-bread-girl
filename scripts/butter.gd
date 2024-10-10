extends Area2D
@onready var label: Label = $Label

func _ready():
	label.hide()

func _on_body_entered(body: Node2D) -> void:
	# Handle butter count in label
	var butter = get_tree().get_nodes_in_group("Butter")
	label.text = str(butter.size() - 1)
	label.show()
	
	# Handle tween animation
	var tween = get_tree().create_tween()
	tween.tween_property(label, "position", Vector2(label.position.x, label.position.y + -10), 0.5).from_current()
	tween.tween_callback(queue_free)
	
	# End level condition
	if butter.size() == 1:
		Events.level_completed.emit()
