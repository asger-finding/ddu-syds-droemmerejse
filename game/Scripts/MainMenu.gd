extends Node2D

func _on_login_button_button_up() -> void:
	Global.GameController.load_scene("LoginMenu")

func _on_register_button_button_up() -> void:
	Global.GameController.load_scene("RegisterMenu")
