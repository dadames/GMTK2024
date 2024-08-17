extends Node2D


@onready var topBoundary: StaticBody2D = %TopBoundary
@onready var bottomBoundary: CollisionObject2D = %BottomBoundary
@onready var leftBoundary: StaticBody2D = %LeftBoundary
@onready var rightBoundary: StaticBody2D = %RightBoundary
@onready var camera: Camera2D = %Camera2D
@onready var level: Level = %Level1

var Score:int = 0
@export var ScoreHit:int = 1
@export var ScoreCatch:int = 1

func _ready() -> void:
	EventBus.score_change.connect(score_change)
	EventBus.level_completed.connect(on_level_completed)
	EventBus.reset_game.connect(reset_game)
	EventBus.debug_complete_level.connect(on_debug_complete_level)
	start_level()
	

func start_level() -> void:
	camera = get_viewport().get_camera_2d()
	camera.scale = Vector2(25 * level.levelScale, 25 * level.levelScale)
	set_boundaries()
	level.initialize()

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

func on_level_completed() -> void:
	print("Level Completed")
	if !level.nextLevel:
		print("Winner")
		return
	var nextLevel := level.nextLevel
	level.queue_free()
	level = nextLevel.instantiate()
	Globals.LEVEL_SCALE = level.levelScale
	level.initialize()
	add_child(level)

func reset_game() -> void:
	print("Resetting game")
	get_tree().reload_current_scene()

func on_debug_complete_level() -> void:
	on_level_completed()

func on_ball_fall() -> void:
	print_debug("Ball Fell ;(")

func _on_bottom_boundary_body_entered(body: Node2D) -> void:
	if body is Ball || body.find_parent("Ball"):
		on_ball_fall()
