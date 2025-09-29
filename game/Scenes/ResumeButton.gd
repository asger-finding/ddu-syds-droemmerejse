extends Button

func _ready():
	pressed.connect(_button_pressed)
	
func _button_pressed() -> void:
	Global.PauseHUD.paused=false
	get_tree().paused=false
