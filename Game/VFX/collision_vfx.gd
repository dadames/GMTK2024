extends CPUParticles2D


const emitTime = 0.5
const lifeTime = 1


func _ready() -> void:
	emitting = true

func _on_finished() -> void:
	queue_free()
