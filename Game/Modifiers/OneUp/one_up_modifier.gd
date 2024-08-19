class_name OneUpModifier
extends Modifier


@export var extraLives: int = 1

func applies_to(gameManager: Node) -> bool:
	return gameManager is GameManager

func apply(gameManager: Node) -> void:
	if applies_to(gameManager):
		for i in range(0, extraLives):
			EventBus.added_available_ball.emit()

func unapply(gameManager: Node) -> void:
	if applies_to(gameManager):
		pass
