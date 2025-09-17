extends CharacterBody2D

class_name Player;

var health := 3
var jump_count := 0
var is_fastfalling := false
var is_rolling := false
var roll_direction := 0 # -1 (left) or 1 (right)
var stun_time := 0.0

var shader_material: ShaderMaterial

@onready var _animated_sprite = $AnimatedSprite2D

# --- Internal functions ---
func _ready() -> void:
	Global.Player = self
	
	var shader_code = '''
	shader_type canvas_item;
	uniform bool white = false;

	void fragment() {
		vec4 tex = texture(TEXTURE, UV);
		if (white) {
			COLOR = vec4(1.0, 1.0, 1.0, tex.a); // full white flash
		} else {
			COLOR = tex;
		}
	}
	'''
	var shader = Shader.new()
	shader.code = shader_code

	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	
	_animated_sprite.material = shader_material

func _process(delta):
	var is_stunned = process_stun(delta)
	if is_stunned:
		move_and_slide()
		return
	
	# Movement animations
	var moving = false
	if is_rolling == true: return

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
			jump_count = 1
		velocity.y += Global.Constants.GRAVITY * delta
	else:
		# Reset jump counter on landing
		jump_count = 0

	# Jump input (Arrow Up or Space)
	if Input.is_action_just_pressed('ui_up') or Input.is_action_just_pressed('ui_accept'):
		if is_on_floor() or jump_count < Global.Constants.MAX_JUMPS:
			velocity.y = Global.Constants.JUMP_VELOCITY
			jump_count += 1
			is_rolling = false
	
	# We lock our horizontal movement if we are rolling
	if is_rolling == true:
		velocity.x = roll_direction * Global.Constants.ROLL_VELOCITY
		move_and_slide()
		return
		
	# Fastfall
	if Input.is_action_just_pressed('ui_down') and !is_on_floor():
		if velocity.y < 0: velocity.y = Global.Constants.FASTFALL_INITIAL_VELOCITY
		velocity.y += Global.Constants.FASTFALL_VELOCITY * delta
	
	# Left-right movement handling
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
		# We deaccelerate in the x axis faster on the ground than in the air
		var deacceleration = Global.Constants.FLOOR_DEACCELERATION if is_on_floor() else Global.Constants.AIR_DEACCELERATION
		velocity.x = move_toward(velocity.x, 0, deacceleration * delta)

# --- Callbacks ---
# Reset rolling state when animation is done
func _on_animated_sprite_2d_animation_finished() -> void:
	if _animated_sprite.animation == 'Roll':
		is_rolling = false

# --- Public methods ---

# Stun method
func stun(time: float) -> bool:
	var already_stunned = stun_time > 0
	if already_stunned:
		return true

	stun_time = time
	return false
	
func process_stun(delta: float) -> bool:
	stun_time = max(0, stun_time - delta)
	var is_stunned = stun_time > 0
	
	if is_stunned:
		is_rolling = false
		
		# Flash player white
		var white = (int(floor(stun_time * 5)) % 2 == 0) if stun_time > delta else false
		_animated_sprite.material.set_shader_parameter('white', white)
	return is_stunned

# Health methods
func get_health() -> int:
	return health

func set_health(new_health: int) -> int:
	health = new_health
	if health < 0: assert(false, 'Health cannot be set to less than 0')
	return health

func heal(count = 1) -> int:
	return _change_health(count)

func deal_damage(count = 1) -> int:
	return _change_health(-count)
	
func _change_health(count: int) -> int:
	health += count
	if health < 0: health = 0
	return health

func is_alive() -> bool:
	return health > 0

# Action states
func get_roll() -> Dictionary:
	return {
		'state': is_rolling,
		'direction': roll_direction
	}

func get_fastfall() -> Dictionary:
	return {
		'state': is_fastfalling
	}
