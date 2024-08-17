class_name Level
extends Node


@export var levelScale: float = 0.001
@export var nextLevel: PackedScene
var bricks: Array[Brick]
@onready var bricks_container: Node2D = $Bricks

func _ready() -> void:
	EventBus.brick_initialized_in_level.connect(on_brick_initialized_in_level)
	EventBus.brick_removed_from_level.connect(on_brick_removed_from_level)

	bricks_container.scale = Vector2.ONE * 2 ** (levelScale - 1)

	for brick: Brick in bricks_container.get_children():
		brick.initialize()

func on_brick_initialized_in_level(brick: Brick) -> void:
	bricks.append(brick)

func on_brick_removed_from_level(brick: Brick) -> void:
	bricks.erase(brick)
	if bricks.is_empty():
		EventBus.level_completed.emit()
