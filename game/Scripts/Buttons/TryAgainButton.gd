extends Button

func _ready():
	pressed.connect(_button_pressed)
	
func _button_pressed() -> void:
	Global.GameController.load_scene("Game")
