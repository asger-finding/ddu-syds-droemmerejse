extends Enemy


var direction
@onready var _animated_sprite = $AnimatedSprite2D
func _physics_process(delta: float) -> void:
	_animated_sprite.play("GodKo")
	if _animated_sprite.flip_h:
		direction = -1
	else:
		direction = 1
	
	# Move horizontally
	velocity.x = Global.Constants.COW_SPEED * direction*delta
	position.x +=velocity.x
	# Apply gravity
	if not is_on_floor():
		velocity.y += Global.Constants.GRAVITY * delta  # gravity value, adjust as needed

	# Check for edge ahead
	if not is_floor_ahead():
		if _animated_sprite.flip_h:
			_animated_sprite.flip_h =false
		else:
			_animated_sprite.flip_h = true

	# Move and slide with floor detection
	move_and_slide()
func is_floor_ahead():
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(Vector2(0, 0), Vector2(50*direction, 15))
	var result = space_state.intersect_ray(query)
	if result:
		var pos = result["position"]
		#print(result["position"])
		print(pos.y)
		#print(position.y)
		return true if pos.y>=20 else false
	else:
		return true
	#return true if result[1].position.y <= position.y else false
	
	
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		print("You took damage")
		body.is_rolling=false
		var direction = -1 if body._animated_sprite.flip_h else 1
		body.velocity += Vector2(1000*(-direction),-700)
		body.velocity.x = move_toward(
			body.velocity.x,
			2000*(-direction),
			Global.Constants.ACCELERATION
			)
		body.health -= 1
		print(body.health)
