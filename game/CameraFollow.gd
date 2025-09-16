extends Camera2D

func _ready() -> void:
	pass

var effective_velocity := 0.0

func _process(delta: float) -> void:
	var player = Global.Player
	if !(player):
		printerr('Player does not exist in Global context. Camera cannot follow.')
		return
	
	position.x = lerp(position.x, player.position.x / 2, Global.Constants.FOLLOW_X_INTERPOLATION_SPEED)
	position.y = min(
		lerp(position.y, player.position.y / 2, Global.Constants.FOLLOW_Y_INTERPOLATION_SPEED),
		Global.Constants.CAMERA_Y_FLOOR
	)
	
	var target_velocity = player.velocity.length()
	var smoothing = 5.0
	effective_velocity = lerp(effective_velocity, target_velocity, smoothing * delta)
	
	var zoom_factor = max(0, -exp(max(effective_velocity - 500, 0) * Global.Constants.CAMERA_ZOOM_PLAYER_SPEED_COEFF) + 2)
	var target_zoom = lerp(Global.Constants.CAMERA_ZOOM_FURTHEST, Global.Constants.CAMERA_ZOOM_CLOSEST, zoom_factor)
	zoom = Vector2.ONE * target_zoom
