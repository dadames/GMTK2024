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
var fallSpeed := 100
var isFalling := false
signal falling()
signal merge()


func _ready() -> void:
	if Engine.is_editor_hint():
		initialize()

func _process(delta: float) -> void:
	if isFalling && !Engine.is_editor_hint():
		position.y += delta * fallSpeed
		var camera := get_viewport().get_camera_2d()
		var cameraPosition: Vector2 = camera.get_screen_center_position()
		var halfSize: Vector2 = Vector2(get_viewport().size) / camera.zoom / 2.0
		var offscreen := cameraPosition.y + (halfSize.y * 1.1)
		if position.y > offscreen:
			print("Fell off screen.")
			queue_free()

func initialize() -> void:
	var levelScale: int
	if !Engine.is_editor_hint():
		levelScale = Globals.LEVEL_SCALE
	else:
		levelScale = get_tree().get_nodes_in_group("Level").front().levelScale
	scale = scale.sign() * levelScale * Globals.SCALE_MODIFIER
	var shape := BrickShape.new()
	shape.shape = shapeType
	set_shape(shape)
	if !Engine.is_editor_hint():
		EventBus.brick_initialized_in_level.emit(self)

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
	falling.emit()

func start_merge() -> void:
	isFalling = false
	merge.emit()

func _exit_tree() -> void:
	EventBus.brick_removed_from_level.emit(self)
