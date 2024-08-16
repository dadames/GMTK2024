@tool
extends Node2D


var brick: Brick


func initialize(brickIn: Brick) -> void:
	brick = brickIn
	modulate = brick.color
