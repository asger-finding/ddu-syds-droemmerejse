extends Node

# --- Inventory state ---
var Gears = 0
var Filling = 0
var Followers = []

# --- Lifecycle ---
func _ready():
	Global.Inventory = self

# --- Public API: Inventory ---
func add_scrap(num: int) -> void:
	if num <= 0:
		assert(false, 'Tried to add zero or less scrap to inventory')
		return
	Gears += num

func add_fluff(num: int) -> void:
	if num <= 0:
		assert(false, 'Tried to add zero or less fluff to inventory')
		return
	Filling += num

func add_follower(identifier: String) -> void:
	if identifier not in Global.Constants.Followers:
		assert(false, 'Follower ID does not exist')
		return
	Followers.push_front(identifier)

func remove_follower(identifier: String) -> void:
	if identifier not in Global.Constants.Followers:
		assert(false, 'Follower ID does not exist')
		return
	var index = Followers.find(identifier)
	var popped = Followers.pop_at(index)
	print('Popped: ', popped)
