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
