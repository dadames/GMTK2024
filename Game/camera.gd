extends Camera2D


var targetZoom: float
var zoomPeriod := 2.0
var zoomSpeed: float

var shakeStrength: float = 0
var shakeMultiplier: float = 1.5
var baseShakeFade: float = 1
var reverseZoom := false


func _ready() -> void:
	EventBus.level_started.connect(on_level_started)
	EventBus.ball_collided.connect(on_ball_collided)
	EventBus.game_over.connect(on_game_over)
	targetZoom = zoom.x

func _process(delta: float) -> void:
	if shakeStrength > 0:
		var shakeFade: float = baseShakeFade * 2 ** (Globals.level_scale + 1)
		shakeStrength = lerpf(shakeStrength, 0, shakeFade * delta)
		offset = random_offset()
	if (!reverseZoom && zoom.x <= targetZoom) || (reverseZoom && zoom.x >= targetZoom):
		return
	if reverseZoom:
		set_zoom(zoom - Vector2(zoomSpeed * delta,zoomSpeed * delta))
	else:
		set_zoom(zoom + Vector2(zoomSpeed * delta,zoomSpeed * delta))
		if zoom.x <= targetZoom:
			EventBus.zoom_finished.emit()

func on_level_started() -> void:
	targetZoom = 2 ** (-Globals.level_scale + 1)
	zoomSpeed = (targetZoom - zoom.x) / zoomPeriod

func random_offset() -> Vector2:
	var rng := RandomNumberGenerator.new()
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength),rng.randf_range(-shakeStrength, shakeStrength))

func on_ball_collided() -> void:
	shakeStrength += 2 ** (Globals.level_scale + 1) * shakeMultiplier

func on_game_over(score: int) -> void:
	targetZoom = 1
	reverseZoom = true
