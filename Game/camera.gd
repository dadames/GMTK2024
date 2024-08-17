extends Camera2D


var targetZoom: int
var zoomSpeed := 0.1
var startTime: float

func _ready() -> void:
	EventBus.level_started.connect(on_level_started)
	targetZoom = zoom.x

func _process(delta: float) -> void:
	if zoom.x == targetZoom:
		return
	var elapsedTime := Time.get_unix_time_from_system() - startTime
	if elapsedTime >= zoomSpeed:
		set_zoom(zoom + Vector2(1,1))
		startTime = Time.get_unix_time_from_system()
	

func on_level_started() -> void:
	targetZoom = Globals.LEVEL_SCALE / 1
	startTime = Time.get_unix_time_from_system()
