@tool
class_name SemiBrick
extends RigidBody2D


var brick: Brick
enum State {Static, Falling, Merged}
var activeState: State = State.Static
var pushed: bool = false

func initialize(brickIn: Brick) -> void:
	brick = brickIn
	$Sprite2D.modulate = brick.color
	brick.falling.connect(on_falling)
	
func _ready() -> void:
	lock_rotation = true

func _physics_process(delta: float) -> void:
	if activeState == State.Falling:
		linear_velocity.y = 100 * Globals.level_factor
		if pushed == false:
			linear_velocity.x = 0
	
#handle size changing because you can't sale rigid bodies for some reason...
func size_change() -> void:
	$Sprite2D.scale = global_scale
	$CollisionShape2D.scale = global_scale
	%LightOccluder2D.scale = global_scale

func collided() -> void:
	match activeState:
		State.Static:
			brick.start_falling()
		State.Falling:
			pass
			#brick.start_merge()

func on_falling() -> void:
	activeState = State.Falling
	#linear_damp = 100
	set_collision_layer_value(2, false)
	set_collision_layer_value(5, true)
	set_collision_mask_value(6, false)
	set_collision_mask_value(7, false)


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if activeState == State.Falling :
		print("entered collision")
		if body.name == "Paddle" :
			pushed = true
	else:
		pass

func _on_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if activeState == State.Falling :
		print("left collision")
		if body.name == "Paddle" :
			pushed = false
	else:
		pass
