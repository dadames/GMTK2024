class_name ModifierObject
extends CharacterBody2D

@onready var icon := %Icon

@export var modifier: Modifier

@export var downward_speed_min := 100.0
@export var downward_speed_max := 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	icon.texture = modifier.icon
	velocity.y = lerp(downward_speed_min, downward_speed_max, randf())

func _physics_process(delta: float) -> void:
	move_and_slide()
