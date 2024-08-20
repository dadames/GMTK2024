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
@onready var static_body: StaticBody2D = %StaticBody2D
@onready var bodies: Array[CollisionObject2D] = [%StaticBody2D, %CollisionDetection, self]
@onready var base_collider: CollisionShape2D = %CollisionShape2D

var _consumed_bricks_this_frame: Array[Brick] = []
var initialized := false
var canMove := true
var gameOver := false

var _modifiers: Array[Resource] = []

func _ready() -> void:
	scale = Vector2(Globals.SCALE_MODIFIER, Globals.SCALE_MODIFIER)
	if Engine.is_editor_hint():
		return
	initialized = true
	EventBus.level_started.connect(on_level_started)
	EventBus.zoom_finished.connect(on_zoom_finished)
	#EventBus.level_completed.connect(on_level_completed)
	#EventBus.zoom_finished.connect(on_zoom_finished)
	EventBus.modifier_collected.connect(_on_modifier_event)
	EventBus.game_over.connect(on_game_over)
	EventBus.game_won.connect(on_game_won)

func _process(delta: float) -> void:
	if !initialized:
		return
	_consumed_bricks_this_frame = []
	if !Engine.is_editor_hint():
		var camera := get_viewport().get_camera_2d()
		var cameraScaling: float = camera.targetZoom / camera.zoom.x 
		if gameOver:
			position.x = 0
		position.y = initialHeight * cameraScaling * 2 ** (Globals.level_scale - 1)
		

func _physics_process(delta: float) -> void:
	if !initialized || Engine.is_editor_hint():
		return
	if canMove:
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * delta * speed
		else:
			velocity.x = move_toward(velocity.x, 0, delta * speed)

		# test move (doesn't move) to push bricks away
		var collision_info := static_body.move_and_collide(velocity * delta, true)
		if collision_info and collision_info.get_collider() is SemiBrick:
			collision_info.get_collider().brick.global_position += collision_info.get_remainder()

		# test move (doesn't move) to explode bricks (if we're in one)
		var collision_info_1 := move_and_collide(velocity * delta, true)
		var collision_info_2 := move_and_collide(-velocity * delta, true)
		if collision_info_1 and collision_info_2:
			var semi_1 := collision_info_1.get_collider() as SemiBrick
			var semi_2 := collision_info_2.get_collider() as SemiBrick

			if semi_1 and semi_2 and semi_1.activeState == SemiBrick.State.Static and semi_2.activeState == SemiBrick.State.Static:
				print_debug("Explode! Explode!")
				semi_1.brick.explode()

		move_and_collide(velocity * delta)

# please provide rects in paddle space, pretty please, if you ignore this you bring woe upon yourself
func consume_brick(brick: Brick, paddle_rect: Rect2, semi_rect: Rect2) -> bool:
	if brick in _consumed_bricks_this_frame:
		return false
	
	# snap to the size of what we're touching
	var grid := Vector2(semi_rect.size.x, Globals.BLOCK_PIXELS * 2 ** roundi(log(paddle_rect.size.y / Globals.BLOCK_PIXELS) / log(2)))

	# offset is based on both the size difference, and the offset of the thing we're connecting to
	var offset := Vector2.UP * ((semi_rect.size.y - grid.y) / 2 - paddle_rect.get_center().y + snappedf(paddle_rect.get_center().y, grid.y))

	#var grid_size: float = Globals.BLOCK_PIXELS * snappedf(brick.global_scale.x, 1.0)
	
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
			parameters.position = self.global_transform * (self.global_transform.affine_inverse() * child.global_position - offset).snapped(grid)
			parameters.collision_mask = 0x4
			if !space_state.intersect_point(parameters, 1).is_empty():
				return false

	_consumed_bricks_this_frame.append(brick)
	
	brick.reparent(self)
	for child: Node2D in brick.get_children():
		if child is SemiBrick:
			EventBus.score_change.emit("Catch")
			for brick_sprite: Sprite2D in child.find_children("Sprite2D"):
				brick_sprite.reparent(self)
				brick_sprite.position = (brick_sprite.position - offset).snapped(grid) + offset
			for brick_collider: CollisionShape2D in child.find_children("CollisionShape2D"):
				for body in bodies:
					var dup := brick_collider.duplicate()
					body.add_child(dup)
					dup.global_position = brick_collider.global_position
					dup.global_scale = brick_collider.global_scale
					dup.position = (dup.position - offset).snapped(grid) + offset
	brick.queue_free()

	return true

func on_level_started() -> void:
	speed = 2 ** Globals.level_scale * initial_speed
	canMove = false

func on_zoom_finished() -> void:
	canMove = true

# Detect when a falling block hits and "catch" it if its hitting us from above
func _on_collision_detection_body_shape_entered(_body_rid:RID, body:Node2D, body_shape_index:int, local_shape_index:int) -> void:
	if body is SemiBrick:
		var body_owner: CollisionShape2D = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
		var local_owner: CollisionShape2D = self.shape_owner_get_owner(self.shape_find_owner(local_shape_index))
		
		var body_rect := body_owner.global_transform * body_owner.shape.get_rect()
		var local_rect := local_owner.global_transform * local_owner.shape.get_rect()
		
		var intersection := body_rect.intersection(local_rect)

		# if we're more through top than side, it's on top
		if intersection.size.x > intersection.size.y && intersection.get_center().y < local_rect.get_center().y:
			consume_brick.call_deferred(body.brick, global_transform.affine_inverse() * local_rect, global_transform.affine_inverse() * body_rect)

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

func on_game_over(score: int) -> void:
	canMove = false
	gameOver = true

func on_game_won(score: int) -> void:
	canMove = false
	gameOver = true
