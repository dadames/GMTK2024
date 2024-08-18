extends TextureButton




func _on_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(2, toggled_on)
