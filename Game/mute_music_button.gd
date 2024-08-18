extends TextureButton




func _on_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(1, toggled_on)
