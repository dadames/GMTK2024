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
	EventBus.zoom_finished.connect(on_zoom_finished)
	EventBus.reset_game.connect(reset_game)
	EventBus.debug_complete_level.connect(on_debug_complete_level)
	start_level.call_deferred(startingLevel)

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
	disable_boundaries()
	add_child(level)
	EventBus.level_started.emit()

func disable_boundaries() -> void:
	topBoundary.set_collision_layer_value(2, false)
	leftBoundary.set_collision_layer_value(2, false)
	rightBoundary.set_collision_layer_value(2, false)
	bottomBoundary.set_collision_layer_value(8, false)
	bottomBoundary.set_collision_mask_value(7, false)

func on_zoom_finished() -> void:
	set_boundaries()

func set_boundaries() -> void:
	var cameraPosition: Vector2 = camera.get_screen_center_position()
	var halfSize: Vector2 = Vector2(get_viewport().size) / camera.zoom / Vector2(2, 2)
	topBoundary.global_position.y = cameraPosition.y - halfSize.y
	bottomBoundary.global_position.y = cameraPosition.y + halfSize.y
	leftBoundary.global_position.x = cameraPosition.x - halfSize.x
	rightBoundary.global_position.x = cameraPosition.x + halfSize.x
	topBoundary.set_collision_layer_value(2, true)
	leftBoundary.set_collision_layer_value(2, true)
	rightBoundary.set_collision_layer_value(2, true)
	bottomBoundary.set_collision_layer_value(8, true)
	bottomBoundary.set_collision_mask_value(7, true)

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
