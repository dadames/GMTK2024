extends TextureRect

var target_scale := 1.0
var scale_period := 2.0
var scale_speed: float
@export var scale_mul := 1.4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.level_started.connect(on_level_started)

func _process(delta: float) -> void:
	if scale.x >= target_scale:
		return

	scale = scale + Vector2.ONE * scale_speed * delta

func on_level_started() -> void:
	target_scale = scale_mul ** (Globals.level_scale - 1)
	scale_speed = (target_scale - scale.x) / scale_period
