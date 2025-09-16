extends Enemy
class_name Ko

func _physics_process(delta: float) -> void:
	pass



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		print("You took damage")
		var direction = -1 if body._animated_sprite.flip_h else 1
		body.velocity += Vector2(1000*(-direction),-1000)
		body.move_and_slide()
	pass # Replace with function body.
