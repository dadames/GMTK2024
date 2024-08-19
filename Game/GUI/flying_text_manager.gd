extends Node


@export var flyingTextPrefab: PackedScene


func _ready() -> void:
	EventBus.generate_flying_text.connect(on_generate_flying_text)

func on_generate_flying_text(position: Vector2, text: String) -> void:
	var flyingText: Label = flyingTextPrefab.instantiate()
	add_child(flyingText)
	flyingText.global_position = position
	flyingText.initialize(text)
