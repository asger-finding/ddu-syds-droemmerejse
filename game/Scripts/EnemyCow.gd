extends Enemy

var dead = false
var direction
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _ray_cast_2d = $RayCast2D
#@onready var _paper_layer = getPaperRoot/PaperLayer
var health = 1
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
		_ray_cast_2d.target_position.x*=(-1)
		#print(_ray_cast_2d.target_position.x)
		if _animated_sprite.flip_h:
			_animated_sprite.flip_h =false
		else:
			_animated_sprite.flip_h = true
	if health <= 0:
		death()
	# Move and slide with floor detection
	move_and_slide()
func is_floor_ahead():
	if _ray_cast_2d.is_colliding():
		var collider = _ray_cast_2d.get_collider()
		if collider:
			return true
		else:
			return false
func death():
	hide()
	set_process(false)
	dead=true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if dead:
		return
	if body is Player:
		print("You took damage")

		var already_stunned = body.stun(1.0)
		if already_stunned:
			return

		var direction = -1 if Global.Player._animated_sprite.flip_h else 1
		body.velocity += Vector2(1000*(-direction),-1500)
		body.velocity.x = move_toward(
			body.velocity.x,
			4000*(-direction),
			Global.Constants.AIR_DEACCELERATION
			)
		body.velocity.y = move_toward(
			body.velocity.y,
			-3000,
			Global.Constants.AIR_DEACCELERATION
			)
		body.health -= 1
		print(body.health)
