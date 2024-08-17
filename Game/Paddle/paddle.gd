@tool

extends CharacterBody2D

const INITIAL_SPEED = 15000.0

var speed: float = INITIAL_SPEED

@export var width: int = 5:
	set(value):
		width = value
		sprite.texture.width = Globals.BLOCK_PIXELS * width
		(base_collider.shape as RectangleShape2D).size.x = Globals.BLOCK_PIXELS * width
		_ready()

@onready var sprite: Sprite2D = $Sprite2D
@onready var bodies: Array[CollisionObject2D] = [%StaticBody2D, %CollisionDetection, self]
@onready var base_collider: CollisionShape2D = %CollisionShape2D


func _ready() -> void:
	scale = Vector2(Globals.SCALE_MODIFIER, Globals.SCALE_MODIFIER)

func _process(_delta: float) -> void:
	if OS.is_debug_build() && !Engine.is_editor_hint() && Input.is_key_pressed(KEY_0):
		for child in get_parent().find_children("Brick"):
			child.position = position
			consume_brick(child, Vector2i.UP + Vector2i.RIGHT)
			break

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
	var camera := get_viewport().get_camera_2d()
	var cameraPosition: Vector2 = camera.get_screen_center_position()
	var halfSize: Vector2 = Vector2(get_viewport().size) / camera.zoom / 4.0
	position.y = cameraPosition.y + (halfSize.y * 0.5)

func consume_brick(brick: Brick, shift: Vector2i = Vector2i.UP + Vector2i.RIGHT) -> void:
	# align the brick to the grid along shift
	brick.position.x += shift.x * fmod(brick.position.x, Globals.BLOCK_PIXELS)# - Globals.BLOCK_PIXELS / 2.0
	brick.position.y += shift.y * fmod(brick.position.x, Globals.BLOCK_PIXELS)# - Globals.BLOCK_PIXELS / 2.0
	for child: Node2D in brick.get_children():
		if child is SemiBrick:
			for brick_sprite: Sprite2D in child.find_children("Sprite2D"):
				brick_sprite.reparent(self)

			for brick_collider: CollisionShape2D in child.find_children("CollisionShape2D"):
				for body in bodies:
					var dup := brick_collider.duplicate()
					body.add_child(dup)
					dup.global_position = brick_collider.global_position
					dup.global_scale = brick_collider.global_scale

	brick.call_deferred("queue_free")

func _on_area_2d_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	call_deferred("consume_brick", body.brick)
