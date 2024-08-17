extends Camera2D


var targetZoom: float
var zoomSpeed := 0.5
var startTime: float

func _ready() -> void:
	EventBus.level_started.connect(on_level_started)
	targetZoom = zoom.x

func _process(delta: float) -> void:
	if zoom.x <= targetZoom:
		return
	set_zoom(zoom - Vector2(zoomSpeed * delta,zoomSpeed * delta))

func on_level_started() -> void:
	targetZoom = 1.0 / Globals.LEVEL_SCALE
