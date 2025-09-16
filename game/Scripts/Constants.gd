extends Node

func _ready():
	# Remember to set as global
	Global.Constants = self

const FOLLOWERS = ["Dog", "Racoon", "Hooker"]

# Camera follow
const FOLLOW_X_INTERPOLATION_SPEED = 0.05 # lerp weight
const FOLLOW_Y_INTERPOLATION_SPEED = 0.5 # lerp weight
const CAMERA_Y_FLOOR = 0 # px
const CAMERA_ZOOM_CLOSEST = 0.6 # coeff of furthest we are zoomed in
const CAMERA_ZOOM_FURTHEST = 0.1 # coeff of furthest we can zoom out
const CAMERA_ZOOM_PLAYER_SPEED_COEFF = 0.0001 # how fast should we zoom out according to player speed

# Player movement
const START_SPEED = 600
const TOP_SPEED = 3000
const ACCELERATION = 4000
const DEACCELERATION = 6000
const JUMP_VELOCITY = -1800
const GRAVITY = 2500
