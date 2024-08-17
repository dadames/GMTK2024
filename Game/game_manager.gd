extends Node2D


var camera: Camera2D
var level: Level


func _ready() -> void:
	start_level()

func start_level() -> void:
	camera = get_viewport().get_camera_2d()
	camera.scale = Vector2(25 * level.scale, 25 * level.scale)
