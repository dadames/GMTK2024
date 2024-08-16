@tool

class_name Brick
extends Node2D


@export var semiBrickPrefab: PackedScene
@export var color: Color:
	set(value):
		color = value
		_ready()
@export var shapeType: BrickShape.ShapeType:
	set(value):
		shapeType = value
		_ready()
@export var mirrored := false:
	set(value):
		mirrored = value
		
		_ready()

var brickScale := 5
var fallSpeed := 10
var falling := false

func _ready() -> void:
	var shape := BrickShape.new()
	shape.shape = shapeType
	initialize(shape)
	falling = true

func _process(delta: float) -> void:
	if falling && !Engine.is_editor_hint():
		position.y += delta * fallSpeed

func initialize(shape: BrickShape) -> void:
	Utilities.clear_children(self)
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

func start_falling() -> void:
	falling = true
