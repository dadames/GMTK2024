class_name Ball
extends CharacterBody2D

@export var baseSpeed: float = 1000
var collide_safe_margin: float = 1.0


func _ready() -> void:
	EventBus.level_started.connect(level_started)
	var angle: float = deg_to_rad(randf_range(60,120))
	velocity = Vector2(cos(angle), sin(angle)) * baseSpeed
	EventBus.added_active_ball.emit()

#Spawn in the ball and scale it
func level_started() -> void:
	var TargetSize:int = Globals.LEVEL_SCALE
	self.scale = Vector2(TargetSize, TargetSize)

#Collision handling
func _physics_process(delta: float) -> void:
	var collisionInfo := move_and_collide(velocity * delta, false, collide_safe_margin)
	if collisionInfo:
		var collider := collisionInfo.get_collider()
		velocity = velocity.bounce(collisionInfo.get_normal())
		if collider.has_method("collided"):
			EventBus.score_change.emit("Hit", Vector2(0,0), Vector2(0,0))
			collider.collided()
		elif collider.is_class("CharacterBody2D"):
			var paddle := collider as CharacterBody2D
			#give paddle velocity to ball
			if paddle.velocity.x != 0:
				pass
				#velocity.x = sign(paddle.velocity.x) * abs(velocity.x)
			if snapped(collisionInfo.get_angle()/PI, 0.1) == 0.5:
				#print(snapped(collisionInfo.get_angle()/PI, 0.1))
				position.x = position.x + (10*sign(velocity.x))
				#print(sign(velocity.x))
	var camera := get_viewport().get_camera_2d()
	var cameraPosition: Vector2 = camera.get_screen_center_position()
	var halfSize: Vector2 = Vector2(get_viewport().size) / camera.zoom / 2.0
	var offscreen := cameraPosition.y + (halfSize.y * 1.1)
	if position.y > offscreen:
		print("Fell off screen.")
		queue_free()

func _exit_tree() -> void:
	EventBus.removed_active_ball.emit()
