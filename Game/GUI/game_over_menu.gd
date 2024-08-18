extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.game_over.connect(on_game_over)
	hide()

func on_game_over(score: int) -> void:
	if score > SaveData.highScore:
		SaveData.highScore = score
		%NewHighScore.show()
	%FinalScore.text = "Final Score: " + str(score)
	%HighScore.text = "High Score: " + str(SaveData.highScore)
	SaveData.save()
	show()
