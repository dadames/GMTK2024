extends Label


var duration: float = 0.5
var fadeTime: float = 0.5
var fading := false


func initialize(textIn: String) -> void:
	scale *= Globals.level_scale
	text = textIn
	await get_tree().create_timer(duration).timeout
	fading = true

func _process(delta: float) -> void:
	if !fading:
		return
	modulate.a -= 1 / fadeTime * delta
	if modulate.a <= 0:
		queue_free()
