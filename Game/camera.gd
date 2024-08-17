extends Camera2D


var targetZoom: int
var zoomSpeed := 1.0

func _ready() -> void:
	EventBus.level_started.connect(on_level_started)
	targetZoom = float(zoom.x)

func _process(delta: float) -> void:
	var nextZoom: float = lerp(float(zoom.x), float(targetZoom), zoomSpeed * delta)
	set_zoom(Vector2(nextZoom, nextZoom))

func on_level_started() -> void:
	targetZoom = 100
	set_zoom(Vector2(targetZoom, targetZoom))
