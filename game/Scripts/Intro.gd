extends Node2D

@onready var anim := $IntroSequence

func _ready() -> void:
	anim.play("default")
	anim.connect("animation_finished", self._on_animation_finished)

func _on_animation_finished() -> void:
	Global.GameController.load_scene("Game")
