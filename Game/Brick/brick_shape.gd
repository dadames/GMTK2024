@tool
class_name BrickShape


enum ShapeType {Line, L, T, S}
var shape := ShapeType.Line

func get_node_orientations() -> Array[Vector2i]:
	var positions: Array[Vector2i]
	match shape:
		ShapeType.Line:
			positions = [Vector2i(-3,0), Vector2i(-1,0), Vector2i(1,0), Vector2i(3,0)]
		ShapeType.L:
			positions = [Vector2i(0,0), Vector2i(-2,0), Vector2i(-2,-2), Vector2i(2,0)]
		ShapeType.T:
			positions = [Vector2i(0,0), Vector2i(-2,0), Vector2i(0,-2), Vector2i(2,0)]
		ShapeType.S:
			positions = [Vector2i(-1,0), Vector2i(1,0), Vector2i(-1,2), Vector2i(1,-2)]
	return positions
