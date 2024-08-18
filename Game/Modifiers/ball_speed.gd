class_name BallSpeedModifier
extends Modifier

@export var factor := 2.0

func applies_to(ball: Node) -> bool:
	return ball is Ball

func apply(ball: Node) -> void:
	if applies_to(ball):
		ball.speed *= factor

func unapply(ball: Node) -> void:
	if applies_to(ball):
		ball.speed /= factor
