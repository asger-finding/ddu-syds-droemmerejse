extends CanvasLayer
var ShopOpen = false

func _ready():
	Global.Shop = self

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Shop"):
		if ShopOpen == false:
			ShopOpen = true
		else:
			ShopOpen = false
		print(ShopOpen)
	if Input.is_action_just_pressed("BuyCow") and ShopOpen:
		Global.Inventory.add_follower("COW")
	if Input.is_action_just_pressed("BuyDragon") and ShopOpen:
		Global.Inventory.add_follower("DRAGON")
	if Input.is_action_just_pressed("BuyShark") and ShopOpen:
		Global.Inventory.add_follower("SHARK")
