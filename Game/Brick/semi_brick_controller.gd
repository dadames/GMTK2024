@tool
class_name SemiBrick
extends StaticBody2D


var brick: Brick
enum State {Static, Falling, Merged}
var activeState: State = State.Static


func initialize(brickIn: Brick) -> void:
	brick = brickIn
	$Sprite2D.modulate = brick.color
	brick.falling.connect(on_falling)

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
