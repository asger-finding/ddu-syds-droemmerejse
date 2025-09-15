extends Node

func _ready():
	# Remember to set as global
	Global.Constants = self

const FOLLOWERS = ["Dog", "Racoon", "Hooker"]

# Player movement constants
const START_SPEED = 100
const TOP_SPEED = 300
const ACCELERATION = 100
const JUMP_VELOCITY = -400
