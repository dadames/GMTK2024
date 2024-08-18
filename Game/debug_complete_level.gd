extends Button


func _ready() -> void:
	if !OS.is_debug_build():
		hide()

func _on_pressed() -> void:
	EventBus.debug_complete_level.emit()
