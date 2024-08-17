extends Node2D


@onready var topBoundary: StaticBody2D = %TopBoundary
@onready var bottomBoundary: StaticBody2D = %BottomBoundary
@onready var leftBoundary: StaticBody2D = %LeftBoundary
@onready var rightBoundary: StaticBody2D = %RightBoundary
@onready var camera: Camera2D = %Camera2D
@onready var level: Level = %Level1

var Score:int = 0
@export var ScoreHit:int = 1
@export var ScoreCatch:int = 1

func _ready() -> void:
	start_level()
	EventBus.score_change.connect(score_change)

func start_level() -> void:
	camera = get_viewport().get_camera_2d()
	camera.scale = Vector2(25 * level.levelScale, 25 * level.levelScale)
	set_boundaries()

func set_boundaries() -> void:
	var cameraPosition: Vector2 = camera.get_screen_center_position()
	var halfSize: Vector2 = Vector2(get_viewport().size) / camera.zoom / Vector2(2, 2)
	topBoundary.global_position.y = cameraPosition.y - halfSize.y
	bottomBoundary.global_position.y = cameraPosition.y + halfSize.y
	leftBoundary.global_position.x = cameraPosition.x - halfSize.x
	rightBoundary.global_position.x = cameraPosition.x + halfSize.x

#score keeping
func score_change(HitType: String) -> void:
	if HitType == "Hit":
		Score += ScoreHit
		#print("Block Hit! New score:",Score)
	elif HitType == "Catch":
		Score += ScoreCatch
		#print("Block Caught! New score:",Score)
