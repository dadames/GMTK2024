extends Node2D


var brickScale := 1

func initialize(shape: BrickShape) -> void:
	var positions = shape.get_node_orientations()
	for position: Vector2i in positions
