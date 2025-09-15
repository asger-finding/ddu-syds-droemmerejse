extends CharacterBody2D

var jump_count: int = 0
const MAX_JUMPS := 2  # 1 = normal jump, 2 = double jump

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += Global.Constants.GRAVITY * delta
	else:
		# Reset jump counter on landing
		jump_count = 0

	# Jump input
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() or jump_count < MAX_JUMPS:
			velocity.y = Global.Constants.JUMP_VELOCITY
			jump_count += 1

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
@onready var _animated_sprite = $AnimatedSprite2D

func _process(_delta):
	if Input.is_action_pressed("ui_right"):
		_animated_sprite.flip_h = false
		_animated_sprite.play("Run")
	if Input.is_action_pressed("ui_left"):
		_animated_sprite.flip_h = true
		_animated_sprite.play("Run")
	if Input.is_action_pressed("ui_down"):
		_animated_sprite.play("Roll")	
	else:
		_animated_sprite.stop()
	move_and_slide()
