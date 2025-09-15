extends Node

@onready var hud := $"HUD"
@onready var game := $"Main2D"

var level_instance

func _ready():
	# Remember to set as global
	Global.GameController = self

func unload_level() -> void:
	if (is_instance_id_valid(level_instance)):
		level_instance.queue_free()
	level_instance = null
	
func load_level(level_name: String) -> void:
	unload_level()
	var path := 'res://Levels/%s.tscn' % level_name
	var level_resource = load(path)
	if (level_resource):
		level_instance = level_resource.instance()
		game.add_child(level_instance)
	else:
		printerr('Level path not found')
