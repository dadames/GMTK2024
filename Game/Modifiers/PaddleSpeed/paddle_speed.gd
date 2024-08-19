class_name PaddleSpeedModifier
extends Modifier

@export var factor := 2.0

func applies_to(paddle: Node) -> bool:
	return paddle is Paddle
	
func apply(paddle: Node) -> void:
	if applies_to(paddle):
		paddle.speed *= factor

func unapply(paddle: Node) -> void:
	if applies_to(paddle):
		paddle.speed /= factor
