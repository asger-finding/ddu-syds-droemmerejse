extends Node

func _ready():
	# Remember to set as global
	Global.Constants = self

const FOLLOWERS = {
	"Cow": "cow_follower",
	"Dragon": "dragon_follower",
	"Shark": "shark_follower"
}

# World
const GRAVITY := 6500.0
