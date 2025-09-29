extends CharacterBody2D

class_name Enemy

@export_enum("Cow", "Dragon", "Shark") var enemy_class = "Cow"
@export_range(0, 10, 1, "suffix:hits") var health: int = 1
@export_range(0, 10, 1, "suffix:healthpoints") var damage: int = 1
@export_range(0, 500.0) var speed: float = 100.0
@export_range(0.0, 3000.0) var knockback_strength: float = 1500.0
@export_range(0.0, 2.0, 0.1, "suffix:s") var stun_time: float = 0.5
@export_range(0, 20) var filling: int = 5

# Path enemy specific property
@export_range(0.0, 5000.0, 50.0, "suffix:px") var flight_or_swim_distance: float = 1000.0

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _edge_raycast = $"Edge Raycast"
@onready var _wall_raycast = $"Wall Raycast"

# Private
var distance_traversed := 0.0 # px
var knockback_time := 0.0
var knockback_velocity := Vector2.ZERO
var player_inside = false

func _ready() -> void:
	_animated_sprite.play(enemy_class)

func _physics_process(delta: float) -> void:
	if Global.PauseHUD.paused:
		_animated_sprite.stop()
		return
	_animated_sprite.play(enemy_class)
	if knockback_time > 0:
		knockback_time -= delta
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 5.0 * delta)
		move_and_slide()
		return
	
	match enemy_class:
		"Cow":
			velocity.x = speed * (-1 if _animated_sprite.flip_h else 1)
			
			# Apply gravity
			if not is_on_floor(): 
				velocity.y += Global.Constants.GRAVITY * delta
			# Check for edge ahead and turn around
			elif is_edge_ahead():
				_edge_raycast.target_position.x *= -1
				_animated_sprite.flip_h = !_animated_sprite.flip_h
			elif not is_wall_ahead():
				_wall_raycast.target_position.x *= -1
				_animated_sprite.flip_h = !_animated_sprite.flip_h
			
		"Dragon", "Shark":
			velocity.x = speed * (-1 if _animated_sprite.flip_h else 1)
			velocity.y = 0
			
			# Track distance traveled
			distance_traversed += abs(velocity.x) * delta
			
			# Turn around when we've traveled the full distance
			if distance_traversed >= flight_or_swim_distance:
				_animated_sprite.flip_h = !_animated_sprite.flip_h
				distance_traversed = 0.0
	
	move_and_slide()

func is_edge_ahead() -> bool:
	var collider = _edge_raycast.get_collider()
	return !(collider and collider != Player)

func is_wall_ahead() -> bool:
	var collider = _wall_raycast.get_collider()
	return !(collider and collider != Player)

func hit(body_that_hit_me: Node2D, hitpoints: int) -> void:
	health -= hitpoints
	if health <= 0:
		kill()
		return
	
	match enemy_class:
		"Cow":
			var lr_direction = -1 if (global_position.x - body_that_hit_me.global_position.x) > 0 else 1
			_edge_raycast.target_position.x = abs(_edge_raycast.target_position.x) * lr_direction
			_animated_sprite.flip_h = true if lr_direction == -1 else false

func receive_knockback(lr_direction: int, strength: float, duration: float = 0.3) -> void:
	knockback_time = duration
	var base_direction = Vector2(lr_direction, 0)
	var knockback_direction = base_direction.rotated(deg_to_rad(-30 * lr_direction))
	match enemy_class:
		"Cow":
			knockback_velocity = knockback_direction * strength
		"Dragon", "Shark":
			knockback_velocity.x = knockback_direction.x * strength

func apply_knockback_to_player(player: Player) -> void:
		# Temporarily disable floor detection
		var original_floor_stop = player.floor_stop_on_slope
		var original_floor_snap = player.floor_snap_length
		player.floor_stop_on_slope = false
		player.floor_snap_length = 0.0
		
		# Apply knockback
		var direction_to_player = (player.global_position - global_position).normalized()
		var lr_direction = sign(direction_to_player.x)
		var collision_angle = direction_to_player.angle() - deg_to_rad(45) * lr_direction
		var opposite_angle = collision_angle
		var launch_direction = Vector2(cos(opposite_angle), sin(opposite_angle))
		player.knockback_player(launch_direction, knockback_strength, true)
		
		# Restore our floor settings
		await get_tree().create_timer(0.1).timeout
		player.floor_stop_on_slope = original_floor_stop
		player.floor_snap_length = original_floor_snap

func spawn_drops() -> void:
	if filling <= 0:
		return
	
	var filling_scene = preload("res://Scenes/CollectibleFilling.tscn")
	var scene_root = get_tree().current_scene
	var drop_position = global_position
	
	for i in range(filling):
		var drop = filling_scene.instantiate()
		drop.filling_frame = randi() % 6
		
		var spawn_offset = Vector2(randf_range(-10, 10), randf_range(-5, 5))
		var random_angle = randf_range(-70, 70)
		var random_speed = randf_range(500, 2000)
		
		var velocity_direction = Vector2.UP.rotated(deg_to_rad(random_angle))
		drop.initial_velocity = velocity_direction * random_speed
		
		scene_root.call_deferred("add_child", drop)
		drop.global_position = drop_position + spawn_offset

func kill() -> void:
	spawn_drops()
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	player_inside = true
	hit_body(body)
	
func hit_body(body):
	if body is Player:
		var player = body
		var already_stunned = player.stun(stun_time)
		if already_stunned or player.is_punching:
			return
		
		apply_knockback_to_player(player)
		player.deal_damage(damage)

func _on_area_2d_body_exited(_body: Node2D) -> void:
	player_inside = false
