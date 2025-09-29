extends CanvasLayer
var ShopOpen = false
var cow_price =10
var dragon_price =15
var shark_price = 20

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
		if Global.Inventory.scrap >= cow_price and Global.Inventory.filling >= cow_price:
			Global.Inventory.scrap -= cow_price
			Global.Inventory.filling -= cow_price
			Global.Player.has_cow = true
			print("Player bought cow")
		else:
			print("broke boy")
	if Input.is_action_just_pressed("BuyDragon") and ShopOpen:
		if Global.Inventory.scrap >= dragon_price and Global.Inventory.filling >= dragon_price:
			Global.Inventory.scrap -= dragon_price
			Global.Inventory.filling -= dragon_price
			Global.Player.has_dragon = true
			print("Player bought dragon")
		else:
			print("broke boy")
	if Input.is_action_just_pressed("BuyShark") and ShopOpen:
		if Global.Inventory.scrap >= shark_price and Global.Inventory.filling >= shark_price:
			Global.Inventory.scrap -= shark_price
			Global.Inventory.filling -= shark_price
			Global.Player.has_shark = true
			print("Player bought shark")
		else:
			print("broke boy")
