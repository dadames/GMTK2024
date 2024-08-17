class_name Level
extends Node


@export var levelScale: int = 5


func _ready() -> void:
	for child: Node in get_children():
		child.initialize()
