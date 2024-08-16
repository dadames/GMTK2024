class_name Utilities


static func get_bitmask(layer: int) -> int:
	return int(pow(2, layer - 1))

static func get_all_directions() -> Array[Vector2i]:
	var directions: Array[Vector2i] = []
	directions.append(Vector2(1, 1))
	directions.append(Vector2i(1, 0))
	directions.append(Vector2(1, -1))
	directions.append(Vector2i(0, -1))
	directions.append(Vector2(-1, -1))
	directions.append(Vector2i(-1, 0))
	directions.append(Vector2(-1, 1))
	directions.append(Vector2i(0, 1))
	return directions

static func get_close_directions(dir: Vector2i) -> Array[Vector2i]:
	var directions: Array[Vector2i] = []
	match dir:
		Vector2i(1, 1):
			directions.append(Vector2i(0, 1))
			directions.append(Vector2i(1, 1))
			directions.append(Vector2i(1, 0))
		Vector2i(1, 0):
			directions.append(Vector2i(1, 1))
			directions.append(Vector2i(1, 0))
			directions.append(Vector2i(1, -1))
		Vector2i(1, -1):
			directions.append(Vector2i(1, 0))
			directions.append(Vector2i(1, -1))
			directions.append(Vector2i(0, -1))
		Vector2i(0, -1):
			directions.append(Vector2i(-1, -1))
			directions.append(Vector2i(0, -1))
			directions.append(Vector2i(1, -1))
		Vector2i(-1, -1):
			directions.append(Vector2i(-1, 0))
			directions.append(Vector2i(-1, -1))
			directions.append(Vector2i(0, -1))
		Vector2i(-1, 0):
			directions.append(Vector2i(-1, 1))
			directions.append(Vector2i(-1, 0))
			directions.append(Vector2i(-1, -1))
		Vector2i(-1, 1):
			directions.append(Vector2i(-1, 0))
			directions.append(Vector2i(-1, 1))
			directions.append(Vector2i(0, 1))
		Vector2i(0, 1):
			directions.append(Vector2i(-1, 1))
			directions.append(Vector2i(0, 1))
			directions.append(Vector2i(1, 1))
		_:
			get_all_directions()
	return directions

static func get_distance_from_position_on_grid(startPosition: Vector2i, endPosition: Vector2i) -> int:
	var xDistance: int = endPosition.x - startPosition.x
	var yDistance: int = endPosition.y - startPosition.y
	return (xDistance * xDistance) + (yDistance * yDistance)

static func get_distance_from_position(startPosition: Vector2, endPosition: Vector2) -> float:
	var xDistance: float = endPosition.x - startPosition.x
	var yDistance: float = endPosition.y - startPosition.y
	return (xDistance * xDistance) + (yDistance * yDistance)

static func check_grid_positions_in_range(startPosition: Vector2i, endPosition: Vector2i, radius: int) -> bool:
	return get_distance_from_position_on_grid(startPosition, endPosition) <= radius * radius

static func check_positions_in_range(startPosition: Vector2, endPosition: Vector2, radius: float) -> bool:
	return get_distance_from_position(startPosition, endPosition) <= radius * radius

static func get_theta(startPosition: Vector2, endPosition: Vector2) -> float:
	var direction := endPosition - startPosition
	var squareSum: float = (direction.x * direction.x) + (direction.y * direction.y)
	return pow(squareSum, 1.0/2.0)

static func get_positive_or_negative() -> int:
	return 1 if randf_range(0, 1) > 0.5 else -1

static func clear_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		child.queue_free()
