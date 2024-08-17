extends CharacterBody2D

@export var speed: float = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Find angle within a 60 degree downward cone
	#then use our angle to determine the direction ball starts
	var angle: float = deg_to_rad(randf_range(60,120))
	velocity = Vector2(cos(angle), sin(angle)) * speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#Move the ball, check for collisions, and bounce off if a collision occurs.
	var CollisionInfo := move_and_collide(velocity * delta)
	if CollisionInfo:
		var CollisionType := CollisionInfo.get_collider()
		velocity = velocity.bounce(CollisionInfo.get_normal())


func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body.is_in_group("Bricks"):
	pass
