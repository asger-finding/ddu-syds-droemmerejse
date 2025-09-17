extends Camera2D

var effective_velocity := 0.0

func _process(delta: float) -> void:
	var player: Player = Global.Player
	if not player:
		assert(false, 'Player does not exist in Global context. Camera cannot follow.')
		return
		
	if not player.is_alive():
		# Player is dead. Intentionally do nothing.
		return
	
	position.x = lerp(position.x, player.position.x / 2, Global.Constants.FOLLOW_X_INTERPOLATION_SPEED * delta)
	position.y = min(
		lerp(position.y, player.position.y / 2, Global.Constants.FOLLOW_Y_INTERPOLATION_SPEED * delta),
		Global.Constants.CAMERA_Y_FLOOR
	)
	
	# Smooth velocity tracking
	var target_velocity := player.velocity.length()
	var smoothing := 5.0
	effective_velocity = lerp(effective_velocity, target_velocity, smoothing * delta)
	
	# Stabilize zoom factor
	var speed_over: float = max(effective_velocity - 500.0, 0.0)
	var zoom_factor: float = clamp(-exp(speed_over * Global.Constants.CAMERA_ZOOM_PLAYER_SPEED_COEFF) + 2.0, 0.0, 1.0)
	
	var target_zoom: float = lerp(Global.Constants.CAMERA_ZOOM_FURTHEST, Global.Constants.CAMERA_ZOOM_CLOSEST, zoom_factor)
	zoom = Vector2.ONE * target_zoom
