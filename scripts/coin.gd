extends Area2D
@onready var coin: Area2D = $"."
@onready var player: CharacterBody2D = $"../Player"



func _on_body_entered(body: Node2D) -> void:
	print("+1")
	player.Money += 1
	coin.queue_free()
