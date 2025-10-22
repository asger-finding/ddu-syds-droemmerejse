extends Node

# --- Prices ---
var Prices = {}

# --- Inventory state ---
var scrap = 0
var filling = 0
var followers = []

# --- Follower State ---
var cow_charges = 3

# --- Lifecycle ---
func _ready():
	Prices[Global.Constants.FOLLOWERS.Cow] = 10
	Prices[Global.Constants.FOLLOWERS.Shark] = 15
	Prices[Global.Constants.FOLLOWERS.Dragon] = 20
	
	Global.Inventory = self

# --- Public API: Inventory ---
func add_scrap(num: int) -> void:
	assert(num > 0, 'Tried to add zero or less scrap to inventory')
	
	scrap += num

func add_filling(num: int) -> void:
	assert(num > 0, 'Tried to add zero or less scrap to inventory')
	
	filling += num

func add_follower(identifier: String) -> void:
	assert(identifier in Global.Constants.FOLLOWERS.values(), "Follower ID does not exist")
	
	# We can't buy the same follower twice
	if identifier in followers: return
	
	# Can we afford the follower?
	if scrap >= Prices[identifier] and filling >= Prices[identifier]:
		followers.push_front(identifier)
		filling -= Prices[identifier]
		scrap -= Prices[identifier]
		
		if identifier == Global.Constants.FOLLOWERS.Cow: cow_charges = 3
		if identifier == Global.Constants.FOLLOWERS.Shark: Global.Shark.spawn()

func remove_follower(identifier: String) -> void:
	assert(identifier in Global.Constants.FOLLOWERS.values(), "Follower ID does not exist")
	assert(identifier in followers, "Tried to remove follower that was not bought")
	
	var index = followers.find(identifier)
	followers.pop_at(index)
