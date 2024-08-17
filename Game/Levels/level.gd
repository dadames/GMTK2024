class_name Level
extends Node


@export var levelScale: float = 0.001
var bricks: Array[Brick]

func _ready() -> void:
	EventBus.brick_initialized_in_level.connect(on_brick_initialized_in_level)
	EventBus.brick_removed_from_level.connect(on_brick_removed_from_level)
	for child: Node in get_children():
		child.initialize()

func on_brick_initialized_in_level(brick: Brick) -> void:
	bricks.append(brick)

func on_brick_removed_from_level(brick: Brick) -> void:
	bricks.erase(brick)
	if bricks.is_empty():
		EventBus.level_completed.emit()
		print("Level Done")
