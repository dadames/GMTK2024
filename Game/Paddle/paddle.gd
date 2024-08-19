@tool

class_name Paddle
extends CharacterBody2D

@export var initial_speed: float = 30000.0
var speed: float = initial_speed
var initialHeight: float = 300

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

var _modifiers: Array[Resource] = []

func _ready() -> void:
	scale = Vector2(Globals.SCALE_MODIFIER, Globals.SCALE_MODIFIER)
	initialized = true
	EventBus.level_started.connect(on_level_started)
	#EventBus.level_completed.connect(on_level_completed)
	#EventBus.zoom_finished.connect(on_zoom_finished)
	EventBus.modifier_collected.connect(_on_modifier_event)

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
		var cameraScaling: float = camera.targetZoom / camera.zoom.x 
		position.y = initialHeight * cameraScaling * 2 ** (Globals.level_scale - 1)

#Movement
func _physics_process(delta: float) -> void:
	if !initialized || Engine.is_editor_hint():
		return
	var direction := Input.get_axis("move_left", "move_right")
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
	
	var grid_size := Globals.BLOCK_PIXELS * snappedf(brick.global_scale.x, 1.0)
	
	#var brick_parity := BrickShape.get_parity(brick.shapeType)
	#brick_parity = abs(((brick_parity as Vector2).rotated(brick.rotation)).snappedf(1.0) as Vector2i)
	
	#if posmod(brick_parity.x, 2) != 0:
	#	brick.position.x -= grid_size * 0.5
	#if posmod(brick_parity.y, 2) != 0:
	#	brick.position.y -= grid_size * 0.5
	#
	## align the brick to the grid along shift
	#brick.position = brick.position.snappedf(grid_size)
	
	#if posmod(brick_parity.x, 2) != 0:
	#	brick.position.x += grid_size * 0.5
	#if posmod(brick_parity.y, 2) != 0:
	#	brick.position.y += grid_size * 0.5
	
	var space_state := get_world_2d().direct_space_state
	
	# check if the spot is actually free
	# if not we return early
	for child: Node2D in brick.get_children():
		if child is SemiBrick:
			var parameters := PhysicsPointQueryParameters2D.new()
			parameters.position = self.global_transform * (self.global_transform.affine_inverse() * child.global_position).snappedf(grid_size)
			parameters.collision_mask = 0x4
			if !space_state.intersect_point(parameters, 1).is_empty():
				return
	
	brick.reparent(self)
	
	for child: Node2D in brick.get_children():
		if child is SemiBrick:
			EventBus.score_change.emit("Catch")
			for brick_sprite: Sprite2D in child.find_children("Sprite2D"):
				brick_sprite.reparent(self)
				brick_sprite.position = brick_sprite.position.snappedf(grid_size)
			for brick_collider: CollisionShape2D in child.find_children("CollisionShape2D"):
				for body in bodies:
					var dup := brick_collider.duplicate()
					body.add_child(dup)
					dup.global_position = brick_collider.global_position
					dup.global_scale = brick_collider.global_scale
					dup.position = dup.position.snappedf(grid_size)
	
	brick.queue_free()



func on_level_started() -> void:
	speed = 2 ** Globals.level_scale * initial_speed


# Detect when a falling block hits and "catch" it if its hitting us from above
func _on_collision_detection_body_shape_entered(_body_rid:RID, body:Node2D, body_shape_index:int, local_shape_index:int) -> void:
	var body_owner: CollisionShape2D = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	var local_owner: CollisionShape2D = self.shape_owner_get_owner(self.shape_find_owner(local_shape_index))
	
	var body_rect := body_owner.global_transform * body_owner.shape.get_rect()
	var local_rect := local_owner.global_transform * local_owner.shape.get_rect()
	
	var intersection := body_rect.intersection(local_rect)
	
	# if we're more through top than side, it's on top
	if intersection.size.x > intersection.size.y && intersection.get_center().y < local_rect.get_center().y:
		call_deferred("consume_brick", body.brick, Vector2.ZERO)

func _on_modifier_event(modifier: Modifier) -> void:
	if modifier.applies_to(self):
		add_modifier(modifier)

func add_modifier(modifier: Modifier) -> void:
	modifier.apply(self)
	_modifiers.append(modifier)

func clear_modifiers() -> void:
	_modifiers.reverse()
	for modifier in _modifiers:
		modifier.unapply(self)
	_modifiers.clear()
