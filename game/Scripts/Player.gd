extends CharacterBody2D
class_name Player

# --- State ---
var health := 0
var jump_count := 0
var is_rolling := false
var is_punching := false
var stun_time := 0.0

# --- References ---
@onready var _animated_sprite: AnimatedSprite2D = $PlayerSprite
@onready var _standing_collision: CollisionShape2D = $StandingCollision
@onready var _rolling_collision: CollisionShape2D = $RollingCollision
@onready var _punch_hitbox: CollisionShape2D = $PlayerSprite/Punch/PunchHitbox

var shader_material: ShaderMaterial

# --- Lifecycle ---
func _ready() -> void:
	Global.Player = self
	
	health = Global.Constants.HEALTH
	
	_standing_collision.disabled = false
	_rolling_collision.disabled = true
	
	_setup_flash_shader()

func _process(delta: float) -> void:
	if is_alive():
		if process_stun(delta):
			return
			
		_handle_animation()
		
	move_and_slide()

func _physics_process(delta: float) -> void:
	_apply_dead_friction(delta)
	_apply_gravity(delta)
	
	if stun_time > 0:
		return
	
	if is_punching:
		return
	
	_punch_hitbox.disabled = true
	
	_handle_jump()
	_handle_roll()
	_handle_punch()
	_handle_horizontal_movement(delta)

# --- Internal: Shader ---
func _setup_flash_shader() -> void:
	var shader_code := '''
	shader_type canvas_item;
	uniform bool white = false;

	void fragment() {
		vec4 tex = texture(TEXTURE, UV);
		COLOR = white ? vec4(1.0, 1.0, 1.0, tex.a) : tex;
	}
	'''
	var shader := Shader.new()
	shader.code = shader_code
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	_animated_sprite.material = shader_material

# --- Internal: Animation ---
func _handle_animation() -> void:
	if is_rolling:
		return
	if is_punching:
		return
	
	var moving := false
	if Input.is_action_just_pressed("ui_down"):
		_start_roll()
		return

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
		if is_on_floor():
			_animated_sprite.play("Idle")
		else:
			_animated_sprite.play("Fall")

# --- Internal: Movement ---
func _apply_dead_friction(delta: float) -> void:
	if not is_alive():
		velocity.x = move_toward(velocity.x, 0, Global.Constants.DEAD_DEACCELERATION * delta)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if jump_count <= 1:
			jump_count = 1
		velocity.y += Global.Constants.GRAVITY * delta
	else:
		jump_count = 0

func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() or jump_count < Global.Constants.MAX_JUMPS:
			velocity.y = -Global.Constants.JUMP_VELOCITY
			jump_count += 1
			is_rolling = false

func _handle_roll() -> void:
	if is_rolling:
		velocity.x = (-1 if _animated_sprite.flip_h else 1) * Global.Constants.ROLL_VELOCITY

func _start_roll() -> void:
	is_rolling = true
	_animated_sprite.play("Roll")
	
	_standing_collision.disabled = true
	_rolling_collision.disabled = false

func _handle_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		if direction * velocity.x <= 0:
			velocity.x = direction * Global.Constants.START_SPEED
		else:
			var ratio: float = abs(velocity.x) / Global.Constants.TOP_SPEED
			var diff := ratio - 0.5
			var sigma := 0.36
			var peak_accel := 2000.0
			var dynamic_accel := peak_accel * exp(-(diff * diff) / (2.0 * sigma * sigma))
			velocity.x = move_toward(
				velocity.x,
				direction * Global.Constants.TOP_SPEED,
				dynamic_accel * delta
			)
	else:
		var deaccel: float = Global.Constants.FLOOR_DEACCELERATION if is_on_floor() else Global.Constants.AIR_DEACCELERATION
		velocity.x = move_toward(velocity.x, 0, deaccel * delta)

func _handle_punch():
	if Input.is_action_just_pressed("Punch"):
		is_rolling = false
		is_punching = true
		_animated_sprite.play("Punch")
		
		var direction = -1 if _animated_sprite.flip_h else 1
		_punch_hitbox.position = Vector2(50 * direction, 0)
		_punch_hitbox.disabled = false
		
		await get_tree().create_timer(0.1).timeout
		_punch_hitbox.disabled = true

# --- Internal: State ---
func kill() -> void:
	print("Player died")
	_animated_sprite.play("Death")

# --- Callbacks ---
func _on_animated_sprite_2d_animation_finished() -> void:
	match _animated_sprite.animation:
		"Roll":
			is_rolling = false
			_standing_collision.disabled = false
			_rolling_collision.disabled = true
			_animated_sprite.play("Idle")
		"Punch":
			is_punching = false
			_punch_hitbox.disabled = true
			_animated_sprite.play("Idle")

func _on_punch_body_entered(body: Node2D) -> void:
	if body is Enemy and body != self:
		var enemy = body
		print("Hit enemy: ", enemy)
		enemy.health -= 1
		enemy.receive_knockback(-1 if _animated_sprite.flip_h else 1, 1500.0)
		_punch_hitbox.disabled = true

# --- Public API: Stun ---
func stun(time: float) -> bool:
	if stun_time > 0:
		return true
	stun_time = time
	return false

func process_stun(delta: float) -> bool:
	stun_time = max(0, stun_time - delta)
	var is_stunned := stun_time > 0

	if is_stunned:
		is_rolling = false
		var white := (int(floor(stun_time * Global.Constants.FLASH_FREQUENCY)) % 2 == 0) if stun_time >= delta else false
		_animated_sprite.material.set_shader_parameter("white", white)
	return is_stunned
	
# --- Public API: Knockback ---
func knockback_player(direction: Vector2, launch_force: float, ignore_current_velocity = true) -> void:
	var new_velocity = direction * launch_force
	
	if ignore_current_velocity:
		print(new_velocity)
		velocity = new_velocity
	else:
		velocity += new_velocity

# --- Public API: Health ---
func get_health() -> int:
	return health

func set_health(new_health: int) -> int:
	assert(new_health >= 0, "Health cannot be set to less than 0")
	health = new_health
	return health

func heal(amount := 1) -> int:
	return _change_health(amount)

func deal_damage(amount := 1) -> int:
	return _change_health(-amount)

func _change_health(delta: int) -> int:
	health = max(0, health + delta)
	if not is_alive(): kill()
	return health

func is_alive() -> bool:
	return health > 0
