extends CharacterBody2D

const STARTSPEED = 100
const TOPSPEED = 300
const ACCELERATION = 100
const JUMP_VELOCITY = -400


func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
	#	velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	#If slower than minimum speed, speed set to minimum speed
	if direction and velocity.x <=STARTSPEED*direction:
		velocity.x=STARTSPEED*direction
	#If moving and slower than top speed, accelerate
	if direction and velocity.x <= TOPSPEED*direction:
		velocity.x += direction * ACCELERATION*delta
	#While moving at top speed, keep moving at top speed
	if direction and velocity.x == TOPSPEED*direction:	
		velocity.x = TOPSPEED*direction
	else:
		velocity.x = move_toward(velocity.x, 0, TOPSPEED)


	move_and_slide()
