@tool
class_name SemiBrick
extends RigidBody2D


var brick: Brick
enum State {Static, Falling, Merged}
var activeState: State = State.Static

func initialize(brickIn: Brick) -> void:
	brick = brickIn
	$Sprite2D.modulate = brick.color
	brick.falling.connect(on_falling)
	
func _ready() -> void:
	lock_rotation = true

func _physics_process(delta: float) -> void:
	if activeState == State.Falling :
		linear_velocity.y = 100 * Globals.level_factor
	pass
	
#handle size changing because you can't sale rigid bodies for some reason...
func size_change(scaleIn: Vector2) -> void:
	$Sprite2D.scale = scaleIn
	$CollisionShape2D.scale = scaleIn
	%LightOccluder2D.scale = scaleIn

func collided() -> void:
	match activeState:
		State.Static:
			brick.start_falling()
		State.Falling:
			pass
			#brick.start_merge()

func on_falling() -> void:
	activeState = State.Falling
	#set_collision_layer_value(4, false)
	set_collision_layer_value(5, true)
	set_collision_mask_value(6, false)
	set_collision_mask_value(7, false)
	set_collision_mask_value(9,true)
