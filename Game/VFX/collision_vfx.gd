extends CPUParticles2D


const emitTime = 0.5
const lifeTime = 1
var initialVelocity: float

func _ready() -> void:
	initial_velocity_min *= 2 ** Globals.level_scale
	initial_velocity_max *= 2 ** Globals.level_scale
	scale_amount_min *= 2 ** Globals.level_scale
	scale_amount_max *= 2 ** Globals.level_scale
	emitting = true

func _on_finished() -> void:
	queue_free()
