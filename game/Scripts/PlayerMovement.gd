extends CharacterBody2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
	#	velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = Global.Constants.JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")

	#If slower than minimum speed, speed set to minimum speed
	if direction and velocity.x <=Global.Constants.START_SPEED * direction:
		velocity.x=Global.Constants.START_SPEED * direction

	#If moving and slower than top speed, accelerate
	if direction and velocity.x <= Global.Constants.TOP_SPEED * direction:
		velocity.x += direction * Global.Constants.ACCELERATION * delta

	#While moving at top speed, keep moving at top speed
	if direction and velocity.x == Global.Constants.TOP_SPEED * direction:	
		velocity.x = Global.Constants.TOP_SPEED * direction
	else:
		velocity.x = move_toward(velocity.x, 0, Global.Constants.TOP_SPEED)

	move_and_slide()
