class_name Level
extends Node


@export var scale: int = 5


func _ready() -> void:
	for child: Node in get_children():
		child.initialize()
