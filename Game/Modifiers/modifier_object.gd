class_name ModifierObject
extends Area2D

@onready var icon := %Icon

@export var modifier: Modifier

@export var downward_speed_min := 100.0
@export var downward_speed_max := 200.0

var speed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	icon.texture = modifier.icon
	speed = lerp(downward_speed_min, downward_speed_max, randf())

func _physics_process(delta: float) -> void:
	position.y += speed * delta

func _on_body_entered(body: Node) -> void:
	if body is Paddle:
		EventBus.modifier_collected.emit(self.modifier)
		EventBus.generate_flying_text.emit(global_position, modifier.flyingText)
		queue_free.call_deferred()
