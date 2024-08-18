extends Node

var highScore: int
var masterVolume: float
var musicVolume: float
var effectsVolume: float
const SAVE_PATH = "user://save_game.dat"

func save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(str(highScore) + ",")
	file.close()

func load() -> void:
	if !FileAccess.file_exists(SAVE_PATH):
		highScore = 0
	else:
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var saveData: PackedStringArray = file.get_as_text().split(",")
		highScore = int(saveData[0])
		file.close()
