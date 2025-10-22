extends Node2D

@onready var _username_input: LineEdit = $"PanelContainer/VBoxContainer/UsernameInput"
@onready var _password_input: LineEdit = $"PanelContainer/VBoxContainer/PasswordInput"
@onready var _error_message: Label = $"ErrorMessage"

func _ready() -> void:
	_error_message.visible = false

func _on_register_button_button_up() -> void:
	var username = _username_input.get_text()
	var password = _password_input.get_text()
	var result = await Global.Backend.post("register", { "username": username, "password": password })

	if (!result["error"]):
		Global.User.playerId = snapped(result.response.player_id, 1)
		Global.Inventory.filling = snapped(result.response.filling, 1)
		Global.Inventory.scrap = snapped(result.response.scrap, 1)
		Global.GameController.load_scene('Game')
	else: handle_error(result["error"])

func handle_error(code: String) -> void:
	_error_message.text = 'Error: ' + code # TODO: human readable errors
	_error_message.visible = true
	await get_tree().create_timer(5).timeout
	_error_message.text = ''
	_error_message.visible = false
