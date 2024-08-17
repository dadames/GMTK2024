@tool
class_name SemiBrick
extends StaticBody2D

var brick: Brick
var hasFallen := false

@onready var sprite: Sprite2D = $Sprite2D

func initialize(brickIn: Brick) -> void:
	brick = brickIn
	sprite.modulate = brick.color
	brick.falling.connect(is_falling)

func collided() -> void:
	if !hasFallen:
		brick.start_falling()
	else:
		brick.stop_falling()

func is_falling() -> void:
	hasFallen = true
	set_collision_layer_value(4, false)
	set_collision_layer_value(5, true)
