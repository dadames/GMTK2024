class_name ModifierBallSize
extends Modifier

@export var factor := 1.0

func applies_to(ball: Node) -> bool:
	return ball is Ball

func apply(ball: Node) -> void:
	if applies_to(ball):
		ball.scale *= factor

func unapply(ball: Node) -> void:
	if applies_to(ball):
		ball.scale /= factor
