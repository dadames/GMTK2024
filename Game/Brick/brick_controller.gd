@tool

class_name Brick
extends Node2D


@export var semiBrickPrefab: PackedScene
var brickScale := 1
var initialized := false

func _ready() -> void:
	var shape := BrickShape.new()
	shape.shape = BrickShape.L
	initialize(shape)


func initialize(shape: BrickShape) -> void:
	var positions := shape.get_node_orientations()
	for quadrantPosition: Vector2i in positions:
		quadrantPosition *= brickScale
		if brickScale == 1:
			spawn_semibrick(quadrantPosition)
		elif brickScale % 2 == 0:
			var offset := brickScale / 2
			for x: int in range(-offset, offset):
				for y: int in range(-offset, offset):
					spawn_semibrick(quadrantPosition + Vector2i(x * 2, y * 2))
		else:
			var offset := (brickScale - 1) / 2
			for x: int in range(-offset, offset + 1):
				for y: int in range(-offset, offset + 1):
					spawn_semibrick(quadrantPosition + Vector2i(x * 2, y * 2))

func spawn_semibrick(quadrantPosition: Vector2) -> void:
	var semibrick: Node2D = semiBrickPrefab.instantiate()
	add_child(semibrick)
	semibrick.position = quadrantPosition
	semibrick.initialize(self)
