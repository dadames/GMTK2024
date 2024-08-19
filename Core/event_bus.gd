extends Node

signal reset_game()
signal debug_complete_level()
signal brick_initialized_in_level(brick: Brick)
signal brick_removed_from_level(brick: Brick)
signal level_completed()
signal level_started()
signal zoom_finished()
signal game_won(score: int)
signal game_over(score: int)
signal score_change(HitType: String)

signal modifier_collected(modifier: Modifier)

signal added_active_ball()
signal removed_active_ball()
signal ball_spawnable()
signal added_available_ball()
signal ball_collided()
signal destroy_ball_called()
signal spawn_extra_ball()
