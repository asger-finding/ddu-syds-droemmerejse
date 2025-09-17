extends Sprite2D

class_name Filling

@export_range(0, 5) var filling_frame: int

func _ready() -> void:
	var loaded_texture = load('res://Assets/Collectibles/filling_%s.png' % filling_frame)
	texture = loaded_texture

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.Inventory.add_fluff(1)

		queue_free()
