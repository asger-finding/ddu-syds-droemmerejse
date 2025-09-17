extends Node

# --- Inventory state ---
var Scrap = 0
var Filling = 0
var Followers = []

# --- Lifecycle ---
func _ready():
	Global.Inventory = self

# --- Public API: Inventory ---
func add_scrap(num: int) -> void:
	assert(num > 0, 'Tried to add zero or less scrap to inventory')

	Scrap += num

func add_fluff(num: int) -> void:
	assert(num > 0, 'Tried to add zero or less scrap to inventory')

	Filling += num

func add_follower(identifier: String) -> void:
	assert(identifier in Global.Constants.Followers, 'Follower ID does not exist')
	
	Followers.push_front(identifier)

func remove_follower(identifier: String) -> void:
	assert(identifier in Global.Constants.Followers, 'Follower ID does not exist')

	var index = Followers.find(identifier)
	var popped = Followers.pop_at(index)
	print('Popped: ', popped)
