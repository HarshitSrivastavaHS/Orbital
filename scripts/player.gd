extends CharacterBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var CurrentItem : Item :
	set(value):
		CurrentItem = value
var StopRunning := false
var InAnimation := false
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
signal health_changed(NewHealth)
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
var Money:= 0
signal HasDied()
@onready var weaponmelee: Sprite2D = $Weaponmelee
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var MaxHealth := 100:
	set(value):
		MaxHealth = value
var CurrentHealth := 100:
	set(value):
		CurrentHealth = clamp(value, 0, MaxHealth)
		health_changed.emit(CurrentHealth)

func _physics_process(delta: float) -> void:
	#death
	if CurrentHealth <= 0:
		HasDied.emit()
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if CurrentItem == null:
		weaponmelee.visible = false
	else:
		weaponmelee.visible = true
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	#flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
		weaponmelee.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		weaponmelee.flip_h = true
	#play animation
	if !InAnimation:
		if is_on_floor():
			if direction == 0 && !StopRunning: 
				if CurrentItem == null :
					animated_sprite.play("idle")
				else:
					animation_player.play("idle")
			elif direction != 0 :
				animated_sprite.play("run")
				StopRunning = true
			else :
				animated_sprite.play("endrun")
		else:
			animated_sprite.play("jump")
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	if Input.is_action_pressed("attack"):
		InAnimation = true
		animated_sprite.play("icestrike")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "endrun":
		StopRunning = false
	if animated_sprite.animation == "icestrike":
		InAnimation = false


func _on_health_changed(NewHealth: Variant) -> void:
	print(NewHealth)


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()


func _on_has_died() -> void:
	Engine.time_scale = 0.5
	if collision_shape and not collision_shape.is_queued_for_deletion():
		print("you died")
		collision_shape.queue_free()
		timer.start()
