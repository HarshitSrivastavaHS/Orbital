extends Node2D
@onready var player: CharacterBody2D = $"../Player"

@onready var timer: Timer = $Timer


func _on_body_entered(body: Node2D) -> void:
	timer.start()


func _on_timer_timeout() -> void:
	player.curr_health -= 10
	if player.curr_health <= 0:
		print("you died")
