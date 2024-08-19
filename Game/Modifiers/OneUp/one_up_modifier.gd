class_name ExtraBallModifier
extends Modifier


@export var extraBalls: int = 1

func applies_to(gameManager: Node) -> bool:
	return gameManager is GameManager

func apply(gameManager: Node) -> void:
	if applies_to(gameManager):
		for i in range(0, extraBalls):
			EventBus.spawn_extra_ball.emit()

func unapply(gameManager: Node) -> void:
	if applies_to(gameManager):
		pass
