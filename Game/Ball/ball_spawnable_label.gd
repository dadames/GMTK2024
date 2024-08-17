extends Label



func _ready() -> void:
	EventBus.ball_spawnable.connect(on_ball_spawnable)
	EventBus.added_active_ball.connect(on_ball_spawned)

func on_ball_spawnable() -> void:
	show()

func on_ball_spawned() -> void:
	hide()
