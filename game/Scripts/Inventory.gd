extends Node

# --- Inventory state ---
var scrap = 0
var filling = 0
var followers = []

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
	assert(identifier in Global.Constants.Followers, 'Follower ID does not exist')
	
	followers.push_front(identifier)

func remove_follower(identifier: String) -> void:
	assert(identifier in Global.Constants.Followers, 'Follower ID does not exist')
	
	var index = followers.find(identifier)
	var popped = followers.pop_at(index)
