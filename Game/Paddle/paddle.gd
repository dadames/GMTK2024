@tool

extends CharacterBody2D

const INITIAL_SPEED = 2000.0

var speed: float = INITIAL_SPEED

@export var width: int = 5:
	set(value):
		width = value
		sprite.texture.width = Globals.BLOCK_PIXELS * width
		(collider.shape as RectangleShape2D).size.x = Globals.BLOCK_PIXELS * width
		_ready()

@onready var sprite: Sprite2D = $Sprite2D
@onready var body: PhysicsBody2D = $StaticBody2D
@onready var collider: CollisionShape2D = %CollisionShape2D

func _process(_delta: float) -> void:
	if OS.is_debug_build() && !Engine.is_editor_hint() && Input.is_key_pressed(KEY_0):
		for child in get_parent().find_children("Brick"):
			child.position = position
			consume_brick(child, Vector2i.UP + Vector2i.RIGHT)
			break

func set_level_scale(level_scale: int) -> void:
	speed = INITIAL_SPEED * 2 ** level_scale

func _ready() -> void:
	set_level_scale(get_tree().get_nodes_in_group("Level").front().levelScale)

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Engine.is_editor_hint():
		return
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * delta * speed
	else:
		velocity.x = move_toward(velocity.x, 0, delta * speed)
	move_and_collide(velocity * delta)

func consume_brick(brick: Brick, shift: Vector2i) -> void:
	# align the brick to the grid along shift
	brick.position.x += shift.x * fmod(brick.position.x, Globals.BLOCK_PIXELS)# - Globals.BLOCK_PIXELS / 2.0
	brick.position.y += shift.y * fmod(brick.position.x, Globals.BLOCK_PIXELS)# - Globals.BLOCK_PIXELS / 2.0
	
	#
	for child_1 in brick.get_children():
		if child_1 is SemiBrick:
			for brick_sprite: Sprite2D in child_1.find_children("Sprite2D"):
				var brick_global_scale := brick_sprite.global_scale
				brick_sprite.get_parent().remove_child(brick_sprite)
				add_child(brick_sprite)
				brick_sprite.global_position = child_1.global_position
				brick_sprite.global_scale = brick_global_scale

			for brick_collider: CollisionShape2D in child_1.find_children("CollisionShape2D"):
				var brick_global_scale := brick_collider.global_scale
				brick_collider.get_parent().remove_child(brick_collider)
				body.add_child(brick_collider)
				brick_collider.global_position = child_1.global_position
				brick_collider.scale = brick_global_scale

	brick.queue_free()
