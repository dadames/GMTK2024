@tool
class_name BrickShape


enum ShapeType {Line, Square, L, T, S}
var shape := ShapeType.Line

func get_node_orientations() -> Array[Vector2i]:
	var positions: Array[Vector2i]
	match shape:
		ShapeType.Line:
			positions = [Vector2i(-48,0), Vector2i(-16,0), Vector2i(16,0), Vector2i(48,0)]
		ShapeType.Square:
			positions = [Vector2i(16,16), Vector2i(-16,16), Vector2i(16,-16), Vector2i(-16,-16)]
		ShapeType.L:
			positions = [Vector2i(0,0), Vector2i(-32,0), Vector2i(-32,-32), Vector2i(32,0)]
		ShapeType.T:
			positions = [Vector2i(0,0), Vector2i(-32,0), Vector2i(0,-32), Vector2i(32,0)]
		ShapeType.S:
			positions = [Vector2i(-16,0), Vector2i(16,0), Vector2i(-16,32), Vector2i(16,-32)]
	return positions

# Return how the nodes are centered around 0, 0
# Parity 0 means it's centered
# Parity 1 means it's along the edges of the nodes
static func get_parity(s: ShapeType) -> Vector2i:
	match s:
		ShapeType.Line:
			return Vector2i(1, 0)
		ShapeType.Square:
			return Vector2i(1, 1)
		ShapeType.L:
			return Vector2i(0, 0)
		ShapeType.T:
			return Vector2i(0, 0)
		ShapeType.S:
			return Vector2i(1, 0)
		_:
			return Vector2i.ZERO

			
