extends Node2D
@onready var player: CharacterBody2D = $"../Player"

@onready var timer: Timer = $Timer


func _on_body_entered(body: Node2D) -> void:
	timer.start()

func _on_body_exited(body: Node2D) -> void:
	timer.stop()

func _on_timer_timeout() -> void:
	player.CurrentHealth -= 2
	
