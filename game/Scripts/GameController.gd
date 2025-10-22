extends Node

@export var default_scene = "MainMenu"
@onready var scene := $'Scene'

var scene_instance

func _ready():
	Global.GameController = self
	# Quit is handled in backend to save our state
	get_tree().set_auto_accept_quit(false)
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
	call_deferred("_add_scene")

func _add_scene():
	scene_instance.visible = false
	scene.add_child(scene_instance)
	await get_tree().process_frame
	scene_instance.visible = true
