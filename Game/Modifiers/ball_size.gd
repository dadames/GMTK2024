extends Modifier

var factor := 2.0

func apply(ball: Node) -> void:
	if ball is Ball:
		ball.scale *= factor

func unapply(ball: Node) -> void:
	if ball is Ball:
		ball.scale /= factor
