extends Node

@onready var hud := $"HUD"
@onready var game := $"Main2D"

var scene_instance

func _ready():
	# Remember to set as global
	Global.GameController = self

func unload_scene() -> void:
	if (is_instance_id_valid(scene_instance)):
		scene_instance.queue_free()
	scene_instance = null
	
func load_scene(scene_name: String) -> void:
	unload_scene()
	var path := 'res://Scenes/%s.tscn' % scene_name
	var scene_resource = load(path)
	if (scene_resource):
		scene_instance = scene_resource.instance()
		game.add_child(scene_instance)
	else:
		printerr('Scene path not found')
