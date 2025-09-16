extends CharacterBody2D

var jump_count: int = 0
const MAX_JUMPS := 5  # 1 = normal jump, 2 = double jump
var is_rolling: bool = false
var roll_velocity := 900  # Adjust for distance
var roll_direction := 0    # -1 or 1
var fastfall = 1
#var fastfallVelocity

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		if jump_count <= 1:
			jump_count=1
		velocity.y += Global.Constants.GRAVITY * delta*fastfall
	else:
		# Reset jump counter on landing
		jump_count = 0
		fastfall =1
	# Jump input
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() or jump_count < MAX_JUMPS:
			velocity.y = Global.Constants.JUMP_VELOCITY
			jump_count += 1
			is_rolling=false
	#locks horizontal movement if rolling
	if is_rolling ==true:
		velocity.x = roll_direction * roll_velocity
		move_and_slide()
		return
		
	# Horizontal input
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		# Accelerate toward top speed
		velocity.x = move_toward(
			velocity.x,
			direction * Global.Constants.TOP_SPEED,
			Global.Constants.ACCELERATION * delta
		)
	else:
		# Decelerate to zero
		velocity.x = move_toward(
			velocity.x,
			0,
			Global.Constants.ACCELERATION * delta
		)
	#Fastfall
	if Input.is_action_just_pressed("ui_down") and !is_on_floor():
		fastfall +1
		if fastfall <=3:
			velocity.y +=500

@onready var _animated_sprite = $AnimatedSprite2D


func _process(_delta):
	#movement animations
	var moving = false
	if is_rolling == true:
		return
	_animated_sprite.speed_scale = 1
	if is_on_floor():
		_animated_sprite.play("Run")
	else:
		_animated_sprite.play("Fald")
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		is_rolling = true
		_animated_sprite.speed_scale = 2
		_animated_sprite.play("Roll")

		# Set direction of roll
		roll_direction = -1 if _animated_sprite.flip_h else 1
		return  # Skip further animation updates this frame
		
		
	if Input.is_action_pressed("ui_right"):
		_animated_sprite.flip_h = false
		if is_on_floor():
			_animated_sprite.play("Run")
			moving = true

	elif Input.is_action_pressed("ui_left"):
		_animated_sprite.flip_h = true
		if is_on_floor():
			_animated_sprite.play("Run")
			moving = true

		 
	if not moving:
		_animated_sprite.stop()
	move_and_slide()

func _on_animated_sprite_2d_animation_finished() -> void:
	if _animated_sprite.animation == "Roll":
		is_rolling = false
		print("roll done :p")
	pass # Replace with function body.
