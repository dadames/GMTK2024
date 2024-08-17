extends Node2D


@onready var topBoundary: StaticBody2D = %TopBoundary
@onready var bottomBoundary: CollisionObject2D = %BottomBoundary
@onready var leftBoundary: StaticBody2D = %LeftBoundary
@onready var rightBoundary: StaticBody2D = %RightBoundary
@onready var camera: Camera2D = %Camera2D
@export var startingLevel: PackedScene
var level: Level

var Distance := 0
var Score:int = 0
@export var ScoreHit:int = 100
@export var ScoreCatch:int = 100

func _ready() -> void:
	EventBus.score_change.connect(score_change)
	EventBus.level_completed.connect(on_level_completed)
	EventBus.reset_game.connect(reset_game)
	EventBus.debug_complete_level.connect(on_debug_complete_level)
	start_level(startingLevel)

func set_boundaries() -> void:
	var cameraPosition: Vector2 = camera.get_screen_center_position()
	var halfSize: Vector2 = Vector2(get_viewport().size) / camera.zoom / Vector2(2, 2)
	topBoundary.global_position.y = cameraPosition.y - halfSize.y
	bottomBoundary.global_position.y = cameraPosition.y + halfSize.y
	leftBoundary.global_position.x = cameraPosition.x - halfSize.x
	rightBoundary.global_position.x = cameraPosition.x + halfSize.x

#score keeping
func score_change(HitType: String, HitPosition: Vector2, PaddlePosition: Vector2) -> void:
	if HitType == "Hit":
		Score += ScoreHit
		#print("Block Hit! New score:",Score)
	elif HitType == "Catch":
		Distance = PaddlePosition.distance_to(HitPosition)
		Score += ((ScoreCatch * (Distance/10)) / 4)
		#print("Block Caught! New score:",Score)

func on_level_completed() -> void:
	print("Level Completed")
	if !level.nextLevel:
		print("Winner")
		return
	start_level(level.nextLevel)

func start_level(nextLevel: PackedScene) -> void:
	if level:
		level.queue_free()
	level = nextLevel.instantiate()
	Globals.LEVEL_SCALE = level.levelScale
	set_boundaries()
	level.initialize()
	add_child(level)
	EventBus.level_started.emit()

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
