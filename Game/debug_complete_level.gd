extends Button



func _on_pressed() -> void:
	EventBus.debug_complete_level.emit()
