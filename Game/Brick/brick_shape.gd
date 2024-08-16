@tool
class_name BrickShape


enum {Line, L, T, S}
var shape := Line

func get_node_orientations() -> Array[Vector2i]:
	var positions: Array[Vector2i]
	match shape:
		Line:
			positions = [Vector2i(0,0), Vector2i(-2,0), Vector2i(2,0)]
		L:
			positions = [Vector2i(0,0), Vector2i(-2,0), Vector2i(-2,-2), Vector2i(2,0)]
		T:
			positions = [Vector2i(0,0), Vector2i(-2,0), Vector2i(0,-2), Vector2i(2,0)]
		S:
			positions = [Vector2i(-1,0), Vector2i(1,0), Vector2i(-1,2), Vector2i(1,-2)]
	return positions
