class_name Level
extends Node


@export var levelScale: float = 0.001


func _ready() -> void:
	for child: Node in get_children():
		child.initialize()
