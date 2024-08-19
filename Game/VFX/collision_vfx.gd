extends Node2D


const emitTime = 0.5
const lifeTime = 1
var initialVelocity: float

func initialize(colorIn: Color) -> void:
	%CollisionVFX.initial_velocity_min *= Globals.level_factor
	%CollisionVFX.scale_amount_min *= Globals.level_factor
	%CollisionVFX.color = colorIn
	%CollisionVFX.emitting = true

func _on_collision_vfx_finished() -> void:
	queue_free()
