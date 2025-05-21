extends CharacterBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var is_holding := false
var stoprunning := false
var in_animation := false
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
signal health_changed(new_health)
	
var max_health := 100:
	set(value):
		max_health = value
var curr_health := 100:
	set(value):
		curr_health = clamp(value, 0, max_health)
		health_changed.emit(curr_health)
		
@onready var weaponmelee: Sprite2D = $Weaponmelee
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if curr_health <= 0:
		get_tree().reload_current_scene()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_holding:
		weaponmelee.visible = true
	else:
		weaponmelee.visible = false
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	#flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	#play animation
	if !in_animation:
		if is_on_floor():
			if direction == 0 && !stoprunning: 
				if is_holding :
					animation_player.play("idle")
				else:
					animated_sprite.play("idle")
			elif direction != 0 :
				animated_sprite.play("run")
				stoprunning = true
			else :
				animated_sprite.play("endrun")
		else:
			animated_sprite.play("jump")
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	#if Health <= 0:
		
	move_and_slide()
	
	if Input.is_action_pressed("attack"):
		in_animation = true
		animated_sprite.play("icestrike")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "endrun":
		stoprunning = false
	if animated_sprite.animation == "icestrike":
		in_animation = false


func _on_health_changed(new_health: Variant) -> void:
	print(new_health)
