extends Control

@onready var hearts_container = $HealthContainer
@onready var filling_label = $FillingContainer/FillingLabel
@onready var scrap_label = $ScrapContainer/ScrapLabel

var last_health = -1
var last_filling = -1
var last_scrap = -1

func _ready():
	update_health()
	update_collectibles()

func _process(_delta):
	var current = Global.Player.get_health()
	if current != last_health:
		last_health = current
		update_health()
	
	if Global.Inventory.Filling != last_filling:
		last_filling = Global.Inventory.Filling
		update_collectibles()
	
	if Global.Inventory.Scrap != last_scrap:
		last_scrap = Global.Inventory.Scrap
		update_collectibles()

func update_health():
	# Clear previous hearts
	for child in hearts_container.get_children():
		child.queue_free()
	
	var max_health = Global.Player.HEALTH
	var current = Global.Player.get_health()

	# Create new sprites
	for i in range(max_health):
		var holder = Control.new()
		holder.custom_minimum_size = Vector2(190, 160)

		var heart = AnimatedSprite2D.new()
		var frames = SpriteFrames.new()
		frames.add_animation("Alive")
		frames.add_frame("Alive", preload("res://Assets/HUD/Health/Alive/frame_0.png"))
		frames.add_frame("Alive", preload("res://Assets/HUD/Health/Alive/frame_1.png"))
		frames.add_animation("Dead")
		frames.add_frame("Dead", preload("res://Assets/HUD/Health/Dead/frame_0.png"))
		frames.add_frame("Dead", preload("res://Assets/HUD/Health/Dead/frame_1.png"))

		heart.frames = frames
		heart.animation = "Alive" if (i < current) else "Dead"
		heart.play(&"", 0.5)
		
		heart.rotation = randf_range(-0.15, 0.15)

		holder.add_child(heart)
		hearts_container.add_child(holder)

func update_collectibles():
	filling_label.text = str(Global.Inventory.Filling)
	scrap_label.text   = str(Global.Inventory.Scrap)
