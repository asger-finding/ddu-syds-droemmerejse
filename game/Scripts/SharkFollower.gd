extends CharacterBody2D

const SPEED = 1800.0

@onready var _shark_sprite = $SharkSprite
@onready var _shark_collision = $SharkCollision
@onready var _shark_ray = $SharkRay
@onready var _player_transform = $PlayerTransform

var enabled = false

func _ready() -> void:
	Global.Shark = self
	set_state(false)
	_player_transform.update_position = true
	_player_transform.update_scale = false
	_player_transform.update_rotation = false

func _process(_delta: float) -> void:
	if not enabled: return
	_player_transform.position = Vector2(10, -70)

func _physics_process(delta: float) -> void:
	if not enabled: return
	
	velocity.y += Global.Constants.GRAVITY * delta
	var dir = -1 if _shark_sprite.flip_h else 1
	velocity.x = SPEED * dir
	
	move_and_slide()
	
	if _shark_ray.is_colliding():
		var collider = _shark_ray.get_collider()
		if collider is TileMap or collider is Enemy: 
			explode()
	
	if is_on_wall():
		explode()

func spawn():
	# Get the player's StandingCollision shape
	var standing_collision = Global.Player._standing_collision
	var shape = standing_collision.shape
	var player_bottom_y = 0.0
	player_bottom_y = standing_collision.global_position.y + (shape.height / 2.0) + shape.radius

	# We get the shark's collision shape to calculate its bottom offset
	var shark_shape = _shark_collision.shape
	var shark_bottom_offset = 0.0
	shark_bottom_offset = _shark_collision.position.y + (shark_shape.height / 2.0) + shark_shape.radius

	# Position the shark so its bottom aligns with the player's bottom
	global_position.y = player_bottom_y - shark_bottom_offset
	global_position.x = Global.Player.global_position.x
	
	# Disable player
	Global.Player._animated_sprite.play("Fall")
	Global.Player.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Flip shark to player direction
	_shark_sprite.flip_h = Global.Player._animated_sprite.flip_h
	set_state(true)
	enabled = true

func explode():
	Global.Inventory.remove_follower(Global.Constants.FOLLOWERS.Shark)
	set_state(false)
	enabled = false
	
	Global.Player.process_mode = Node.PROCESS_MODE_INHERIT
	
	knockback_player()

func knockback_player():
	var dir = 1 if _shark_sprite.flip_h else -1
	Global.Player.velocity += Vector2(dir * 3000, -3000)

func set_state(enabled_state):
	enabled = enabled_state
	_shark_collision.disabled = not enabled_state
	_shark_ray.enabled = enabled_state
	visible = enabled_state
	velocity = Vector2.ZERO
	
	if enabled:
		_player_transform.remote_path = _player_transform.get_path_to(Global.Player)
	else:
		_player_transform.remote_path = NodePath("")
