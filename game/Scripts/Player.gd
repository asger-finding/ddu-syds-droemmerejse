extends CharacterBody2D

class_name Player;

var jump_count := 0
var is_rolling := false
var roll_direction := 0 # -1 (left) or 1 (right)
var fastfall := 1
var fastfall_count := 1
var health := 3

@onready var _animated_sprite = $AnimatedSprite2D

# Define our Player globally
func _ready() -> void:
	Global.Player = self

func _process(_delta):
	# movement animations
	var moving = false
	if is_rolling == true:
		return

	_animated_sprite.speed_scale = 1
	if is_on_floor():
		_animated_sprite.play('Run')
	else:
		_animated_sprite.play('Fald')
	if Input.is_action_just_pressed('ui_down') and is_on_floor():
		is_rolling = true
		_animated_sprite.speed_scale = 2
		_animated_sprite.play('Roll')
	
		# Set direction of roll
		roll_direction = -1 if _animated_sprite.flip_h else 1
		return  # Skip further animation updates this frame
	
	if Input.is_action_pressed('ui_right'):
		_animated_sprite.flip_h = false
		if is_on_floor():
			_animated_sprite.play('Run')
			moving = true
	
	elif Input.is_action_pressed('ui_left'):
		_animated_sprite.flip_h = true
		if is_on_floor():
			_animated_sprite.play('Run')
			moving = true
	
	if not moving: _animated_sprite.stop()

	move_and_slide()
	
	if health == 0:
		print('you r died')
		hide()
		set_process(false)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		if jump_count <= 1:
			jump_count=1
		velocity.y += Global.Constants.GRAVITY * fastfall * delta
	else:
		# Reset jump counter on landing
		jump_count = 0
		fastfall = 1
	
	# Jump input
	if Input.is_action_just_pressed('ui_accept'):
		if is_on_floor() or jump_count < Global.Constants.MAX_JUMPS:
			velocity.y = Global.Constants.JUMP_VELOCITY
			jump_count += 1
			is_rolling = false
	
	# We lock our horizontal movement if we are rolling
	if is_rolling == true:
		velocity.x = roll_direction * Global.Constants.ROLL_VELOCITY
		move_and_slide()
		return
	
	var direction := Input.get_axis('ui_left', 'ui_right')
	if direction != 0:
		# If our player is at standstill,
		# we want to instantly accelerate him.
		# Else, we follow a curved acceleration profile
		if direction * velocity.x <= 0:
			velocity.x = direction * Global.Constants.START_SPEED
		else:
			var ratio = abs(velocity.x) / Global.Constants.TOP_SPEED
			var center = 0.5
			var sigma = 0.36
			var peak_accel = 2000.0
			var diff = ratio - center
			var dynamic_accel = peak_accel * exp(- (diff * diff) / (2.0 * sigma * sigma))
			velocity.x = move_toward(
				velocity.x,
				direction * Global.Constants.TOP_SPEED,
				dynamic_accel * delta
			)
	else:
		var deacceleration = Global.Constants.FLOOR_DEACCELERATION if is_on_floor() else Global.Constants.AIR_DEACCELERATION
		velocity.x = move_toward(velocity.x, 0, deacceleration * delta)
	
	# Fastfall
	if Input.is_action_just_pressed('ui_down') and !is_on_floor():
		fastfall = 2
		fastfall_count += 1
		if fastfall_count <= 3:
			velocity.y +=500

func _on_animated_sprite_2d_animation_finished() -> void:
	if _animated_sprite.animation == 'Roll':
		is_rolling = false
		#print('roll done :p')
	pass # Replace with function body.
