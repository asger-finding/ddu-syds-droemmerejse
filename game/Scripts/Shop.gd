extends CanvasLayer

var BUY_ACTIONS := {
	"BuyCow": Global.Constants.FOLLOWERS.Cow,
	"BuyDragon": Global.Constants.FOLLOWERS.Dragon,
	"BuyShark": Global.Constants.FOLLOWERS.Shark
}

@onready var shop_sprite: AnimatedSprite2D = $Shop

func _ready() -> void:
	Global.Shop = self
	visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Shop"): visible = not visible
	if not visible: return
	
	shop_sprite.global_position = Global.Player.global_position
	shop_sprite.global_position.y -= 500

	# Disable buying a duplicate follower
	match [
		Global.Constants.FOLLOWERS.Cow in Global.Inventory.followers,
		Global.Constants.FOLLOWERS.Dragon in Global.Inventory.followers
	]:
		[true, true]:
			shop_sprite.play("001")
		[true, false]:
			shop_sprite.play("011")
		[false, true]:
			shop_sprite.play("101")
		_:
			shop_sprite.play("111")
	
	for action in BUY_ACTIONS:
		if Input.is_action_just_pressed(action):
			var identifier = BUY_ACTIONS[action]
			assert(identifier in Global.Constants.FOLLOWERS.values(), "Follower ID does not exist")
			
			if identifier in Global.Inventory.followers: return
			
			Global.Inventory.add_follower(identifier)
			visible = false
