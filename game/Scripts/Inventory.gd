extends Node

# --- Prices ---
const CowPrice =10
const DragonPrice =15
const SharkPrice=20
const Prices = {"COW" : CowPrice, "DRAGON": DragonPrice, "SHARK": SharkPrice}
# --- Inventory state ---
var scrap = 100
var filling = 100
var followers = []
# --- Follower State ---
var cow_charges = 3
# --- Lifecycle ---
func _ready():
	Global.Inventory = self

# --- Public API: Inventory ---
func add_scrap(num: int) -> void:
	assert(num > 0, 'Tried to add zero or less scrap to inventory')
	
	scrap += num

func add_filling(num: int) -> void:
	assert(num > 0, 'Tried to add zero or less scrap to inventory')
	
	filling += num

func add_follower(identifier: String) -> void:
	assert(identifier in Global.Constants.FOLLOWERS, 'Follower ID does not exist')
	if not identifier in followers:
		if scrap and filling >= Prices[identifier]:
			followers.push_front(identifier)
			filling -= Prices[identifier]
			scrap -= Prices[identifier]
			print(followers)
			if identifier == "COW":
				cow_charges =3
		else:
			print("you a broke boy")
	else:
		print("follower already bought")

func remove_follower(identifier: String) -> void:
	assert(identifier in Global.Constants.FOLLOWERS, 'Follower ID does not exist')
	if identifier in followers:
		var index = followers.find(identifier)
		var popped = followers.pop_at(index)
	else:
		print("follower already bought")
