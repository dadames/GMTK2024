extends Camera2D


var targetZoom: float
var zoomPeriod := 2.0
var zoomSpeed: float

func _ready() -> void:
	EventBus.level_started.connect(on_level_started)
	targetZoom = zoom.x

func _process(delta: float) -> void:
	if zoom.x <= targetZoom:
		return
	set_zoom(zoom + Vector2(zoomSpeed * delta,zoomSpeed * delta))
	if zoom.x <= targetZoom:
		EventBus.zoom_finished.emit()

func on_level_started() -> void:
	targetZoom = 2 ** (-Globals.level_scale + 1)
	zoomSpeed = (targetZoom - zoom.x) / zoomPeriod
