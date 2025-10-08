extends Node2D

@onready var anim := $IntroSequence

func _ready() -> void:
	anim.play("default")
	anim.connect("animation_finished", self._on_animation_finished)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE):
		anim.pause()
		Global.GameController.load_scene("Game")

func _on_animation_finished() -> void:
	Global.GameController.load_scene("Game")
