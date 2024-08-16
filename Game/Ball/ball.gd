extends CharacterBody2D

const SPEED = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2.DOWN * SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var CollisionInfo := move_and_collide(velocity * delta)
	if CollisionInfo:
		velocity = velocity.bounce(CollisionInfo.getnormal())
