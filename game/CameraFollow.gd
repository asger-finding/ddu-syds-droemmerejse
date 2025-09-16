extends Camera2D

func _ready() -> void:
	pass

func _process(delta) -> void:
	position.x = Global.Player.position.x / 2
	position.y = Global.Player.position.y / 2
