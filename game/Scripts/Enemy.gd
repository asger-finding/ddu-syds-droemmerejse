extends CharacterBody2D

class_name Enemy

@export_enum("Cow", "Dragon", "Shark") var enemy_class = "Cow"
@export_range(0, 10, 1, "suffix:hits") var health: int = 1
@export_range(0, 10, 1, "suffix:healthpoints") var damage: int = 1
@export_range(0, 500.0) var speed: float = 100.0
@export_range(0.0, 3000.0) var knockback_strength: float = 1500.0
@export_range(0.0, 2.0, 0.1, "suffix:s") var stun_time: float = 0.5

# Path enemy specific property
@export_range(0.0, 5000.0, 50.0, "suffix:px") var flight_or_swim_distance: float = 1000.0

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _edge_raycast = $"Edge Raycast"

# Private
var distance_traversed := 0.0 # px

func _ready() -> void:
	_animated_sprite.play(enemy_class)

func _process(_delta: float) -> void:
	if health <= 0:
		kill()

func _physics_process(delta: float) -> void:
	match enemy_class:
		"Cow":
			velocity.x = speed * (-1 if _animated_sprite.flip_h else 1)
			
			# Apply gravity
			if not is_on_floor(): 
				velocity.y += Global.Constants.GRAVITY * delta
			
			# Check for edge ahead and turn around
			if is_edge_ahead():
				_edge_raycast.target_position.x *= -1
				_animated_sprite.flip_h = !_animated_sprite.flip_h
			
		"Dragon", "Shark":
			velocity.x = speed * (-1 if _animated_sprite.flip_h else 1)
			
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

func apply_knockback_to_player(player: Player) -> void:
		# Temporarily disable floor detection
		var original_floor_stop = player.floor_stop_on_slope
		var original_floor_snap = player.floor_snap_length
		player.floor_stop_on_slope = false
		player.floor_snap_length = 0.0
		
		# Apply knockback
		var direction_to_player = (player.global_position - global_position).normalized()
		var collision_angle = direction_to_player.angle()
		var opposite_angle = collision_angle
		var launch_direction = Vector2(cos(opposite_angle), sin(opposite_angle))
		var knockback_force = 1500.0
		player.knockback(launch_direction, knockback_force, true)
		
		# Restore our floor settings
		await get_tree().create_timer(0.1).timeout
		player.floor_stop_on_slope = original_floor_stop
		player.floor_snap_length = original_floor_snap

func kill() -> void:
	# TODO: Add fluffing drops
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body
		var already_stunned = player.stun(stun_time)
		if already_stunned:
			return
			
		print("You took damage")
			
		apply_knockback_to_player(player)
		player.deal_damage(damage)
