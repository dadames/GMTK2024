@tool

extends CharacterBody2D

const INITIAL_SPEED = 18000.0

var speed: float = INITIAL_SPEED

@export var width: int = 5:
	set(value):
		width = value
		sprite.texture.width = Globals.BLOCK_PIXELS * width
		(collider.shape as RectangleShape2D).size.x = Globals.BLOCK_PIXELS * width
		_ready()

@onready var sprite: Sprite2D = $Sprite2D
@onready var body: PhysicsBody2D = $StaticBody2D
@onready var collider: CollisionShape2D = $StaticBody2D/CollisionShape2D

func set_level_scale(level_scale: int) -> void:
	scale = 2.0 ** -level_scale * Vector2.ONE

func _ready() -> void:
	set_level_scale(get_tree().get_nodes_in_group("Level").front().levelScale)

func _process(_delta: float) -> void:
	if OS.is_debug_build() && !Engine.is_editor_hint() && Input.is_key_pressed(KEY_0):
		for child in get_parent().find_children("Brick"):
			consume_brick(child, Vector2i(0, 0))
			break

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Engine.is_editor_hint():
		return
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * delta * INITIAL_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, delta * INITIAL_SPEED)

	move_and_slide()

func consume_brick(brick: Brick, destination: Vector2i) -> void:
	add_child(brick)

	var position_offset := Globals.BLOCK_PIXELS * (destination as Vector2 - Vector2(0.5, 0.5))
	#var position_offset := Globals.BLOCK_PIXELS * destination as Vector2
	
	for child_1 in brick.get_children():
		if child_1 is SemiBrick:
			for brick_sprite: Sprite2D in child_1.find_children("Sprite2D"):
				brick_sprite.get_parent().remove_child(brick_sprite)
				add_child(brick_sprite)
				brick_sprite.position = child_1.position + position_offset

			for brick_collider: CollisionShape2D in child_1.find_children("CollisionShape2D"):
				brick_collider.get_parent().remove_child(brick_collider)
				body.add_child(brick_collider)
				brick_collider.position = child_1.position + position_offset

	brick.queue_free()
