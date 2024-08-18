extends Node2D


@onready var topBoundary: StaticBody2D = %TopBoundary
@onready var leftBoundary: StaticBody2D = %LeftBoundary
@onready var rightBoundary: StaticBody2D = %RightBoundary
@onready var bottomBoundary: CollisionObject2D = %BottomBoundary
var topBoundaryPosition: float = -384
var leftBoundaryPosition: float = -512
var rightBoundaryPosition: float = 512
var bottomBoundaryPosition: float = 384

@onready var camera: Camera2D = %Camera2D
@export var startingLevel: PackedScene
var level: Level
@export var ballPrefab: PackedScene

var distance := 0
var score:int = 0
@export var scoreHit:int = 100
@export var scoreCatch:int = 100
var availableBalls: int = 3
var activeBalls: int = 0
var ballSpawnable := true

func _ready() -> void:
	EventBus.score_change.connect(score_change)
	EventBus.level_completed.connect(on_level_completed)
	EventBus.zoom_finished.connect(on_zoom_finished)
	EventBus.reset_game.connect(reset_game)
	EventBus.debug_complete_level.connect(on_debug_complete_level)
	EventBus.added_active_ball.connect(on_added_active_ball)
	EventBus.removed_active_ball.connect(on_removed_active_ball)
	EventBus.added_available_ball.connect(on_added_available_ball)
	start_level.call_deferred(startingLevel)
	set_boundaries.call_deferred()
	%BallLabel.text = str(availableBalls)
	SaveData.load()

func score_change(HitType: String, HitPosition: Vector2, PaddlePosition: Vector2) -> void:
	if HitType == "Hit":
		score += scoreHit
		#print("Block Hit! New score:",score)
	elif HitType == "Catch":
		score = PaddlePosition.distance_to(HitPosition)
		score += ((scoreCatch * (score/10)) / 4)
		#print("Block Caught! New score:",score)
	EventBus.update_score.emit(score)

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
	Globals.level_scale = level.levelScale
	disable_boundaries()
	add_child.call_deferred(level)
	EventBus.level_started.emit()

func disable_boundaries() -> void:
	topBoundary.set_collision_layer_value(2, false)
	leftBoundary.set_collision_layer_value(2, false)
	rightBoundary.set_collision_layer_value(2, false)
	bottomBoundary.set_collision_layer_value(8, false)
	bottomBoundary.set_collision_mask_value(7, false)

func on_zoom_finished() -> void:
	set_boundaries()
	show_ball_spawnable()

func set_boundaries() -> void:
	var camera := get_viewport().get_camera_2d()
	var cameraScaling: float = camera.targetZoom / camera.zoom.x 
	topBoundary.global_position.y = topBoundaryPosition * cameraScaling * 2 ** (Globals.level_scale - 1)
	leftBoundary.global_position.x = leftBoundaryPosition * cameraScaling * 2 ** (Globals.level_scale - 1)
	rightBoundary.global_position.x = rightBoundaryPosition * cameraScaling * 2 ** (Globals.level_scale - 1)
	bottomBoundary.global_position.y = bottomBoundaryPosition * cameraScaling * 2 ** (Globals.level_scale - 1)
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
		
	if body is ModifierObject:
		body.queue_free.call_deferred()

func spawn_ball() -> void:
	var newBall := ballPrefab.instantiate()
	add_child(newBall)
	ballSpawnable = false
	%BallLabel.text = str(availableBalls)

func on_added_active_ball() -> void:
	activeBalls += 1
	availableBalls -=1

func on_removed_active_ball() -> void:
	activeBalls -= 1
	if activeBalls <= 0:
		if availableBalls > 0:
			show_ball_spawnable()
		else:
			EventBus.game_over.emit(score)

func on_added_available_ball() -> void:
	availableBalls += 1
	%BallLabel.text = str(availableBalls)

func show_ball_spawnable() -> void:
	ballSpawnable = true
	EventBus.ball_spawnable.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn_ball") && ballSpawnable:
		spawn_ball()
