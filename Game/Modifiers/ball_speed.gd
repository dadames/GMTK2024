class_name BallSpeedModifier
extends Modifier

@export var factor := 2.0

func apply(ball: Node) -> void:
	if ball is Ball:
		ball.speed *= factor

func unapply(ball: Node) -> void:
	if ball is Ball:
		ball.speed /= factor
