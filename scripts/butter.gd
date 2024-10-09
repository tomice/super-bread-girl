extends Area2D

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	var butter = get_tree().get_nodes_in_group("Butter")
	if butter.size() == 1:
		Events.level_completed.emit()
