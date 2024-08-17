extends Node

signal reset_game()
signal brick_initialized_in_level(brick: Brick)
signal brick_removed_from_level(brick: Brick)
signal level_completed()
signal game_over()

signal score_change(HitType: String)
