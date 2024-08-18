extends Node

const BLOCK_PIXELS := 32
const SCALE_MODIFIER := 1#0.00001
var LEVEL_SCALE: float = 1

func _ready() -> void:
	EventBus.level_started.connect(level_started)

#Scale the grid for bricks snapping to paddle
func level_started() -> void:
	pass
