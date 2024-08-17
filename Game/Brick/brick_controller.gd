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
		if value && scale.x > 0:
			scale.x *= -1
		elif !value && scale.x < 0:
			scale.x *= -1
		_ready()
var fallSpeed := 10
var isFalling := false
signal falling()


func _ready() -> void:
	if Engine.is_editor_hint():
		initialize()

func _process(delta: float) -> void:
	if isFalling && !Engine.is_editor_hint():
		position.y += delta * fallSpeed

func initialize() -> void:
	scale = scale.normalized() * 2 ** get_tree().get_nodes_in_group("Level").front().levelScale
	var shape := BrickShape.new()
	shape.shape = shapeType
	set_shape(shape)

func set_shape(shape: BrickShape) -> void:
	Utilities.clear_children(self)
	var positions := shape.get_node_orientations()
	for quadrantPosition: Vector2i in positions:
		spawn_semibrick(quadrantPosition)

func spawn_semibrick(quadrantPosition: Vector2) -> void:
	var semibrick: Node2D = semiBrickPrefab.instantiate()
	add_child(semibrick)
	semibrick.position = quadrantPosition
	semibrick.initialize(self)

func start_falling() -> void:
	isFalling = true
	print("A")

func stop_falling() -> void:
	isFalling = false
