extends Node

func _ready():
	Global.Inventory = self

# Set default values
var scrap_amount = 0
var fluff_amount = 0
var followers = []

func add_scrap(num: int) -> void:
	if num <= 0:
		printerr("Tried to add zero or less scrap to inventory")
		return
	scrap_amount += num

func add_fluff(num: int) -> void:
	if num <= 0:
		printerr("Tried to add zero or less fluff to inventory")
		return
	fluff_amount += num

func add_follower(identifier: String) -> void:
	if identifier not in Global.Constants.FOLLOWERS:
		printerr('Follower ID does not exist')
		return
	followers.push_front(identifier)

func remove_follower(identifier: String) -> void:
	if identifier not in Global.Constants.FOLLOWERS:
		printerr('Follower ID does not exist')
		return
	var index = followers.find(identifier)
	var popped = followers.pop_at(index)
	print("Popped:", popped)
