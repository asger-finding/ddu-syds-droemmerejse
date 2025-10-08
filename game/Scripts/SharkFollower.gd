extends CharacterBody2D


const SPEED = 2000.0
const JUMP_VELOCITY = -400.0
@onready var _shark_sprite = $SharkSprite
@onready var _shark_hitbox = $SharkHitbox
@onready var _shark_ray = $SharkRay
var counter = 0

func _ready() -> void:
	Global.Shark = self
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not "SHARK" in Global.Inventory.followers:
		return

	if not is_on_floor():
		velocity.y += Global.Constants.GRAVITY
		
	var dir = -1 if Global.Player._animated_sprite.flip_h else 1
	_shark_sprite.flip_h = true if Global.Player._animated_sprite.flip_h else false
	velocity.x = SPEED*dir

	move_and_slide()
	
func _process(delta: float) -> void:
	if not "SHARK" in Global.Inventory.followers:
		_shark_sprite.visible = false
		_shark_hitbox.disabled = true
		_shark_ray.enabled = false
		counter = 0
		return
	else:
		counter +=1
		if counter == 1:
			set_pos()
		_shark_sprite.visible = true
		_shark_hitbox.disabled = false
		
		Global.Player.position = position + Vector2(80,-178)
	var collider = _shark_ray.get_collider()
	print(collider)
	if collider is TileMapLayer or collider is Enemy: 
		explode()
func explode():
	Global.Inventory.remove_follower("SHARK")
	jump()
func jump():
	var dir = -1 if _shark_sprite.flip_h else 1
	Global.Player.velocity += Vector2(-dir*5000,-5000)
func set_pos():
	position = Global.Player.position
	_shark_ray.enabled = true
