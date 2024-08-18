extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.game_over.connect(on_game_over)
	hide()

func on_game_over(score: int) -> void:
	%FinalScore.text = "Final Score: " + str(score)
	show()
