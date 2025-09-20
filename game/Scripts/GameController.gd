extends Node

@export var default_scene = "Intro"
@onready var scene := $'Scene'

var scene_instance

func _ready():
	Global.GameController = self
	load_scene(default_scene)

func unload_scene() -> void:
	if is_instance_valid(scene_instance):
		scene_instance.queue_free()
	scene_instance = null

func load_scene(scene_name: String) -> void:
	unload_scene()
	var path := 'res://Scenes/%s.tscn' % scene_name
	var scene_resource = load(path)
	assert(scene_resource, 'Tried to load scene, but provided scene path was not found')

	scene_instance = scene_resource.instantiate()
	scene.add_child(scene_instance)
