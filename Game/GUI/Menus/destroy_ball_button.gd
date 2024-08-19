extends Button


func _on_pressed() -> void:
	EventBus.destroy_ball_called.emit()
