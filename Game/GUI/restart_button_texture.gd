extends TextureButton


func _on_pressed() -> void:
	EventBus.reset_game.emit()
