extends CharacterBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var CurrentItem : Item :
	set(value):
		CurrentItem = value
var InAnimation := false
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
signal health_changed(NewHealth)
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
var Money:= 0
var ComboCounter := 1
signal HasDied()
var MaxHealth := 100:
	set(value):
		MaxHealth = value
var CurrentHealth := 100:
	set(value):
		CurrentHealth = clamp(value, 0, MaxHealth)
		health_changed.emit(CurrentHealth)
@onready var marker: Marker2D = $Marker2D

func _physics_process(delta: float) -> void:
	#print(animation_player.current_animation)
	
	#death
	if CurrentHealth <= 0:
		HasDied.emit()
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	#flip the sprite
	if direction > 0:
		marker.scale.x = 1
	elif direction < 0:
		marker.scale.x = -1
	
	#play animation
	if !InAnimation:
		if is_on_floor():
			if direction == 0: 
				animation_player.play("idle")
			else:
				animation_player.play("run")
		else:
			animation_player.play("jump")
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("attack"):
		if !InAnimation:
			InAnimation = true
			AttackAnimation()

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


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	InAnimation = false
	#print(anim_name)

func AttackAnimation():
	if CurrentItem != null:
		animation_player.play(CurrentItem.animation + Combo(CurrentItem.animation))
		ComboCounter += 1
	if ComboCounter > 3:
		ComboCounter = 1

func Combo(animation):
	if animation in ["Ruler"]:
		return "_" + str(ComboCounter)
	else:
		return ""
