extends CharacterBody2D

@export var baseSpeed: float = 1000


func _ready() -> void:
	var angle: float = deg_to_rad(randf_range(60,120))
	velocity = Vector2(cos(angle), sin(angle)) * baseSpeed

func _physics_process(delta: float) -> void:
	var collisionInfo := move_and_collide(velocity * delta)
	if collisionInfo:
		var collider := collisionInfo.get_collider()
		velocity = velocity.bounce(collisionInfo.get_normal())
		if collider.has_method("collided"):
			collider.collided()
		elif collider.is_class("CharacterBody2D"):
			var paddle := collider as CharacterBody2D
			if paddle.velocity.x != 0:
				velocity.x = sign(paddle.velocity.x) * abs(velocity.x)
