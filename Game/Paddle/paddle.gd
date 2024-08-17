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
	sprite.texture.width = Globals.BLOCK_PIXELS * width
	(collider.shape as RectangleShape2D).size.x = Globals.BLOCK_PIXELS * width

#func _process(delta: float) -> void:
#	if Input.is_key_pressed(KEY_0):
#		for child in get_parent().find_children("Brick"):
#			add_brick(child, Vector2i(0, 0))
#			break

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * delta * INITIAL_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, delta * INITIAL_SPEED)

	move_and_slide()

func add_brick(brick: Brick, destination: Vector2i) -> void:
	add_child(brick)

	brick.position.x = Globals.BLOCK_PIXELS * destination.x
	brick.position.y = Globals.BLOCK_PIXELS * destination.y
	
	for child_1 in brick.get_children():
		if child_1 is SemiBrick:
			for brick_sprite: Sprite2D in child_1.find_children("Sprite2D"):
				brick_sprite.get_parent().remove_child(brick_sprite)
				add_child(brick_sprite)
				brick_sprite.position = child_1.position

	remove_child(brick)
