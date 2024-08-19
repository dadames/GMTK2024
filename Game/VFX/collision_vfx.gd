extends CPUParticles2D


const emitTime = 0.5
const lifeTime = 1
var initialVelocity: float

func initialize(colorIn: Color) -> void:
	initial_velocity_min *= Globals.level_scale
	initial_velocity_max *= Globals.level_scale
	scale_amount_min *= Globals.level_scale
	scale_amount_max *= Globals.level_scale
	color = colorIn
	emitting = true

func _on_finished() -> void:
	queue_free()
