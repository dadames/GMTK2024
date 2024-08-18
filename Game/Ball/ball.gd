class_name Ball
extends CharacterBody2D

@export var baseSpeed: float = 250
@export var min_speeds := Vector2(25, 100)
var collide_safe_margin: float = 1.0
var speed: float
@onready var blockBounceAudio: AudioStreamPlayer2D = %BlockBounceAudio
@onready var paddleBounceAudio: AudioStreamPlayer2D = %PaddleBounceAudio
@onready var wallBounceAudio: AudioStreamPlayer2D = %WallBounceAudio
@export var collisionVFXPrefab: PackedScene

var _modifiers: Array[Resource] = []


func _ready() -> void:
	EventBus.level_completed.connect(on_level_completed)
	EventBus.modifier_collected.connect(_on_modifier_event)
	speed = baseSpeed * Globals.level_factor
	var targetSize := Globals.level_scale
	self.scale = Vector2(targetSize, targetSize)
	%CPUParticles2D.emission_sphere_radius = 128
	var angle: float = deg_to_rad(randf_range(60,120))
	velocity = Vector2(cos(angle), sin(angle)) * speed
	EventBus.added_active_ball.emit()

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

func on_level_completed() -> void:
	EventBus.added_available_ball.emit()
	queue_free()

#Collision handling
func _physics_process(delta: float) -> void:
	var collisionInfo := move_and_collide(velocity * delta, false, collide_safe_margin)
	if collisionInfo:
		var collider := collisionInfo.get_collider()
		velocity = velocity.bounce(collisionInfo.get_normal())
		if collider.has_method("collided"):
			EventBus.score_change.emit("Hit", Vector2(0,0), Vector2(0,0))
			var vfx: CPUParticles2D = collisionVFXPrefab.instantiate()
			get_tree().root.add_child(vfx)
			vfx.global_position = collisionInfo.get_position()
			collider.collided()
			blockBounceAudio.play()
		elif collider.is_class("CharacterBody2D"):
			print("Paddle")
			var paddle := collider as CharacterBody2D
			#give paddle velocity to ball
			if paddle.velocity.x != 0:
				pass
				#velocity.x = sign(paddle.velocity.x) * abs(velocity.x)
			if snapped(collisionInfo.get_angle()/PI, 0.1) == 0.5:
				#print(snapped(collisionInfo.get_angle()/PI, 0.1))
				position.x = position.x + (10*sign(velocity.x))
				#print(sign(velocity.x))
			paddleBounceAudio.play()
		else:
			wallBounceAudio.play()
	if abs(velocity.x) < min_speeds.x:
		match sign(velocity.x):
			0: velocity.x = ((randi() % 2) * 2 - 1) * min_speeds.x
			var s: velocity.x = s * min_speeds.x
	if abs(velocity.y) < min_speeds.y:
		match sign(velocity.y):
			0: velocity.y = -min_speeds.y
			var s: velocity.y = s * min_speeds.y

	# set always to speed
	velocity = velocity.normalized() * speed

	var camera := get_viewport().get_camera_2d()
	var cameraPosition: Vector2 = camera.get_screen_center_position()
	var halfSize: Vector2 = Vector2(get_viewport().size) / camera.zoom / 2.0
	var offscreen := cameraPosition.y + (halfSize.y * 1.1)

	if position.y > offscreen:
		queue_free()

func _exit_tree() -> void:
	EventBus.removed_active_ball.emit()
