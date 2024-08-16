@tool
extends Node2D


var brick: Brick
var hasFallen := false


func initialize(brickIn: Brick) -> void:
	brick = brickIn
	modulate = brick.color
	brick.falling.connect(is_falling)

func collided() -> void:
	if !hasFallen:
		brick.start_falling()

func is_falling() -> void:
	hasFallen = true
