extends Sprite2D

var collect=0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		collect+=1
		hide()
		set_process(false)
		if collect ==1:
			Global.Inventory.add_fluff(1)
	pass # Replace with function body.
