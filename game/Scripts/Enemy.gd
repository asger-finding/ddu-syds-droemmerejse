extends Enemy


func _physics_process(delta: float) -> void:
	_animated_sprite.play("GodKo")
	pass

@onready var _animated_sprite = $AnimatedSprite2D

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
