@tool

extends CharacterBody2D

@export var initial_speed: float = 30000.0
var speed: float = initial_speed

@export var width: int = 5:
	set(value):
		width = value
		sprite.texture.width = Globals.BLOCK_PIXELS * width
		(base_collider.shape as RectangleShape2D).size.x = Globals.BLOCK_PIXELS * width
		_ready()

@onready var sprite: Sprite2D = $Sprite2D
@onready var bodies: Array[CollisionObject2D] = [%StaticBody2D, %CollisionDetection, self]
@onready var base_collider: CollisionShape2D = %CollisionShape2D

var _consumed_bricks_this_frame: Array[Brick] = []
var initialized := false

func _ready() -> void:
	scale = Vector2(Globals.SCALE_MODIFIER, Globals.SCALE_MODIFIER)
	initialized = true
	EventBus.level_started.connect(on_level_started)
	#EventBus.level_completed.connect(on_level_completed)
	#EventBus.zoom_finished.connect(on_zoom_finished)

func _process(_delta: float) -> void:
	if !initialized:
		return
	_consumed_bricks_this_frame = []
	if OS.is_debug_build() && !Engine.is_editor_hint() && Input.is_key_pressed(KEY_0):
		for child in get_parent().find_children("Brick"):
			child.position = position
			consume_brick(child, Vector2i.UP + Vector2i.RIGHT)
			break
	if !Engine.is_editor_hint():
		var camera := get_viewport().get_camera_2d()
		var test: float = camera.targetZoom / camera.zoom.x 
		position.y = 330 * test * 2 ** (Globals.level_scale - 1)

#Movement
func _physics_process(delta: float) -> void:
	if !initialized || Engine.is_editor_hint():
		return
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * delta * speed
	else:
		velocity.x = move_toward(velocity.x, 0, delta * speed)
	move_and_collide(velocity * delta)


func consume_brick(brick: Brick, shift: Vector2) -> void:
	if brick in _consumed_bricks_this_frame:
		return

	#print_debug(brick, shift)
	_consumed_bricks_this_frame.append(brick)

	brick.reparent(self)

	var grid_size := Globals.BLOCK_PIXELS * 2 ** (Globals.level_scale - 1)

	var brick_parity := BrickShape.get_parity(brick.shapeType)
	brick_parity = abs(((brick_parity as Vector2).rotated(brick.rotation)).snappedf(1.0) as Vector2i)

	if posmod(brick_parity.x, 2) != 0:
		brick.position.x -= grid_size * 0.5
	if posmod(brick_parity.y, 2) != 0:
		brick.position.y -= grid_size * 0.5
	
	# align the brick to the grid along shift
	brick.position = brick.position.snappedf(grid_size)

	if posmod(brick_parity.x, 2) != 0:
		brick.position.x += grid_size * 0.5
	if posmod(brick_parity.y, 2) != 0:
		brick.position.y += grid_size * 0.5
	
	for child: Node2D in brick.get_children():
		if child is SemiBrick:
			EventBus.score_change.emit("Catch", brick.position, position)
			for brick_sprite: Sprite2D in child.find_children("Sprite2D"):
				brick_sprite.reparent(self)

			for brick_collider: CollisionShape2D in child.find_children("CollisionShape2D"):
				for body in bodies:
					var dup := brick_collider.duplicate()
					body.add_child(dup)
					dup.global_position = brick_collider.global_position
					dup.global_scale = brick_collider.global_scale

	brick.queue_free()



func on_level_started() -> void:
	speed = 2 ** Globals.level_scale * initial_speed


#Detect when a falling block hits and "catch" it if its hitting us from above
func _on_collision_detection_body_shape_entered(body_rid:RID, body:Node2D, body_shape_index:int, local_shape_index:int) -> void:
	print("detected")
	#call_deferred("consume_brick", body.brick, Vector2.ZERO)
	var Direction: Vector2 = (body.global_position - global_position).normalized()
	var Side: float = Direction.angle_to(Vector2.RIGHT)
	var Angle:int = rad_to_deg(Side)
	if Angle > 15 and Angle < 165 : #Defines what "above" means
			call_deferred("consume_brick", body.brick, Vector2.ZERO)
		#print("within angle. angle is:", Angle, " or ", Side)
	#else:
		#print("outside of angle. angle is:", Angle, " or ", Side)
		
	## FAILED EXPERIMENT DO NOT DELETE
	#var local_owner := shape_owner_get_owner(local_shape_index) as Node2D
	#var body_owner := shape_owner_get_owner(body_shape_index) as Node2D

	#var local_shape: Shape2D = local_owner.shape
	#var body_shape: Shape2D = body_owner.shape

	#var local_rect: Rect2 = local_shape.get_rect()
	#var body_rect: Rect2 = body_shape.get_rect()

	#var local_transform := local_owner.global_transform
	#var body_transform := body_owner.global_transform

	#var contacts := local_shape.collide_and_get_contacts(local_transform, body_shape, body_transform)

	#print_debug(contacts)

	#var contacts_average := Vector2.ZERO

	#for i in range(contacts.size() / 2):
	#	print_debug(contacts[2 * i + 1] - contacts[2 * i])
	#	contacts_average += (contacts[2 * i + 1] - contacts[2 * i]) / (contacts.size() as float / 2.0)

	#print_debug(contacts_average)

	#var direction := contacts_average
	#print_debug("direction", direction)

	#var shift := Vector2.ZERO

	#if abs(direction.x) < abs(direction.y):
	#	shift.y = sign(direction.y) * (Globals.BLOCK_PIXELS / 2.0)
	#else:
	#	shift.x = sign(direction.x) * (Globals.BLOCK_PIXELS / 2.0)

	#print_debug(shift)

	#call_deferred("consume_brick", body.brick, shift)
	
