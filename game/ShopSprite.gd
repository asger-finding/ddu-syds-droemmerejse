extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.Shop.ShopOpen:
		visible=true
		if "COW" in Global.Inventory.followers and "DRAGON" in Global.Inventory.followers:
			play("001")
			return
		if "COW" in Global.Inventory.followers:
			play("011")
			return
		if "DRAGON" in Global.Inventory.followers:
			play("101")
			return
		else:
			play("111")
	else:
		visible=false
	pass
