extends Node

func _ready():
	# Remember to set as global
	Global.Constants = self

const FOLLOWERS = ["Dog", "Racoon", "Hooker"]

# Camera follow
const FOLLOW_X_INTERPOLATION_SPEED = 0.05 # lerp weight
const FOLLOW_Y_INTERPOLATION_SPEED = 0.5 # lerp weight
const CAMERA_Y_FLOOR = 0 # px
const CAMERA_ZOOM_COEFF = 0.0005
const CAMERA_ZOOM_FURTHEST = 0.2 # coeff of furthest we zoom out
const CAMERA_ZOOM_PLAYER_SPEED_COEFF = 0.0005 # how fast should we zoom out according to player speed

# Player movement
const START_SPEED = 100
const TOP_SPEED = 500
const ACCELERATION = 3000
const JUMP_VELOCITY = -700
const GRAVITY = 1500
