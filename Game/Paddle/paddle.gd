@tool

extends CharacterBody2D

const INITIAL_SPEED = 18000.0

var speed: float = INITIAL_SPEED

@export var width: int = 5:
	set(value):
		width = value
		_ready()

@onready var sprite: Sprite2D = $Sprite2D
@onready var collider: CollisionShape2D = $StaticBody2D/CollisionShape2D

func _ready() -> void:
	sprite.texture.width = 32 * width
	(collider.shape as RectangleShape2D).size.x = 32 * width

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * delta * INITIAL_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, delta * INITIAL_SPEED)

	move_and_slide()
