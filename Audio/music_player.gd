extends AudioStreamPlayer


@export var soundtrack: Array[AudioStream]
var currentIndex: int = 0


func _ready() -> void:
	stream = soundtrack[0]
	play()

func _on_finished() -> void:
	currentIndex += 1
	if currentIndex >= soundtrack.size():
		currentIndex = 0
	stream = soundtrack[currentIndex]
	play()
