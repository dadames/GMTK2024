extends Node2D


@onready var topBoundary: StaticBody2D = %TopBoundary
@onready var bottomBoundary: StaticBody2D = %BottomBoundary
@onready var leftBoundary: StaticBody2D = %LeftBoundary
@onready var rightBoundary: StaticBody2D = %RightBoundary
@onready var camera: Camera2D = %Camera2D
@onready var level: Level = %Level1


func _ready() -> void:
	start_level()

func start_level() -> void:
	camera = get_viewport().get_camera_2d()
	camera.scale = Vector2(25 * level.scale, 25 * level.scale)
	set_boundaries()

func set_boundaries() -> void:
	var cameraPosition: Vector2 = get_viewport().get_camera_2d().get_screen_center_position()
	var halfY: float = get_viewport().size.y / camera.scale.y
	print(get_viewport().size)
	topBoundary.global_position.y = cameraPosition.y - halfY
	bottomBoundary.global_position.y = cameraPosition.y + halfY
	var halfX: float = get_viewport().size.x / camera.scale.x
	leftBoundary.global_position.x = cameraPosition.x - halfX
	rightBoundary.global_position.x = cameraPosition.x + halfX
