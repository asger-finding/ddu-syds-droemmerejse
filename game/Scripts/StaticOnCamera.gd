extends CanvasLayer

@export var camera_reference: Camera2D
var start_position: Vector2

func _ready() -> void:
	start_position = position

func _process(_delta) -> void:
	if camera_reference:
		position = camera_reference.position + start_position
