class_name GameManager
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
var score:float = 0
@export var scoreHit:float = 1
#@export var scoreCatch:int = 100
@export var availableBalls: int = 5
var activeBalls: int = 0
var ballSpawnable := true
var isLevelTransition := false

func _ready() -> void:
	EventBus.score_change.connect(score_change)
	EventBus.level_completed.connect(on_level_completed)
	EventBus.zoom_finished.connect(on_zoom_finished)
	EventBus.reset_game.connect(reset_game)
	EventBus.debug_complete_level.connect(on_debug_complete_level)
	EventBus.added_active_ball.connect(on_added_active_ball)
	EventBus.removed_active_ball.connect(on_removed_active_ball)
	EventBus.added_available_ball.connect(on_added_available_ball)
	EventBus.modifier_collected.connect(on_modifier_event)
	EventBus.spawn_extra_ball.connect(on_spawn_extra_ball)
	EventBus.ball_lost.connect(on_ball_lost)
	start_game.call_deferred()
	%BallLabel.text = str(availableBalls)
	%ScoreLabel.text = str(score)
	SaveData.load()

func start_game() -> void:
	start_level(startingLevel)
	set_boundaries()
	EventBus.zoom_finished.emit()

func score_change(HitType:String) -> void:
	if HitType == "Catch":
		score += (scoreHit / 4)
		#print("Block Hit! New score:",score)
	#elif HitType == "Catch":
	#	score = PaddlePosition.distance_to(HitPosition)
	#	score += ((scoreCatch * (score/10)) / 4)
	#	#print("Block Caught! New score:",score)
	%ScoreLabel.text = str(score)

func on_level_completed() -> void:
	isLevelTransition = true
	print("Level Completed")
	%Paddle.clear_modifiers()
	if !level.nextLevel:
		#Globals.level_scale = 1
		EventBus.game_won.emit(score)
		level.hide_bricks()
		disable_boundaries()
		%BallSpawnVisualizer.hide()
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
	%BallSpawnVisualizer.hide()

func disable_boundaries() -> void:
	topBoundary.set_collision_layer_value(2, false)
	leftBoundary.set_collision_layer_value(2, false)
	rightBoundary.set_collision_layer_value(2, false)
	bottomBoundary.set_collision_layer_value(8, false)
	bottomBoundary.set_collision_mask_value(7, false)

func on_zoom_finished() -> void:
	set_boundaries()
	isLevelTransition = false
	show_ball_spawnable()

func set_boundaries() -> void:
	var camera := get_viewport().get_camera_2d()
	var cameraScaling: float = camera.targetZoom / camera.zoom.x 
	topBoundary.global_position.y = topBoundaryPosition * cameraScaling * 2 ** (Globals.level_scale - 1)
	leftBoundary.global_position.x = leftBoundaryPosition * cameraScaling * 2 ** (Globals.level_scale - 1)
	rightBoundary.global_position.x = rightBoundaryPosition * cameraScaling * 2 ** (Globals.level_scale - 1)
	bottomBoundary.global_position.y = bottomBoundaryPosition * cameraScaling * 2 ** (Globals.level_scale - 1)
	print("new height: ", bottomBoundary.global_position. y - topBoundary.global_position.y)
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
	newBall.global_position = Vector2(0,(64 * 2 ** (Globals.level_scale -1)))
	print("ball spawning at: ", newBall.global_position)
	add_child(newBall)
	ballSpawnable = false
	%BallLabel.text = str(availableBalls)
	%BallSpawnVisualizer.hide()

func on_added_active_ball() -> void:
	activeBalls += 1
	availableBalls -=1

func on_removed_active_ball() -> void:
	activeBalls -= 1
	if activeBalls <= 0:
		if availableBalls > 0:
			if !isLevelTransition:
				show_ball_spawnable()
		else:
			level.hide_bricks()
			disable_boundaries()
			%BallSpawnVisualizer.hide()
			Globals.level_scale = 1
			EventBus.game_over.emit(score)

func on_added_available_ball() -> void:
	availableBalls += 1
	%BallLabel.text = str(availableBalls)

func show_ball_spawnable() -> void:
	ballSpawnable = true
	%BallSpawnVisualizer.global_position = Vector2(0,(64 * 2 ** (Globals.level_scale-1)))
	%BallSpawnVisualizer.scale = Vector2(0.075, 0.075) * Vector2(Globals.level_factor, Globals.level_factor)
	%BallSpawnVisualizer.show()
	EventBus.ball_spawnable.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn_ball") && ballSpawnable:
		call_deferred("spawn_ball")

func on_modifier_event(modifier: Modifier) -> void:
	if modifier.applies_to(self):
		add_modifier(modifier)

func add_modifier(modifier: Modifier) -> void:
	modifier.apply(self)

func on_spawn_extra_ball() -> void:
	availableBalls += 1
	call_deferred("spawn_ball")

func on_ball_lost() -> void:
	%BallLostAudio.play()
