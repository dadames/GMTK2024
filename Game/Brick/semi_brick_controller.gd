@tool
class_name SemiBrick
extends StaticBody2D

var brick: Brick
enum State {Static, Falling, Merged}
var activeState: State = State.Static

@onready var sprite: Sprite2D = $Sprite2D

func initialize(brickIn: Brick) -> void:
	brick = brickIn
	sprite.modulate = brick.color
	brick.falling.connect(on_falling)
	brick.merge.connect(on_merge)

func collided() -> void:
	match activeState:
		State.Static:
			brick.start_falling()
		State.Falling:
			brick.start_merge()
		State.Merged:
			get_parent().consume_brick()

func on_falling() -> void:
	activeState = State.Falling
	set_collision_layer_value(4, false)
	set_collision_layer_value(5, true)

func on_merge() -> void:
	activeState = State.Merged
	set_collision_layer_value(5, true)
	set_collision_layer_value(2, true)
	set_collision_layer_value(7, true)
