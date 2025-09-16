extends Node

func _ready():
	# Remember to set as global
	Global.Constants = self

const FOLLOWERS = ['Dog', 'Racoon', 'Hooker']

# Camera follow
const FOLLOW_X_INTERPOLATION_SPEED = 8.5 # lerp weight
const FOLLOW_Y_INTERPOLATION_SPEED = 85 # lerp weight
const CAMERA_Y_FLOOR = 0 # px
const CAMERA_ZOOM_CLOSEST = 0.4 # coeff of furthest we are zoomed in
const CAMERA_ZOOM_FURTHEST = 0.05 # coeff of furthest we can zoom out
const CAMERA_ZOOM_PLAYER_SPEED_COEFF = 0.0001 # how fast should we zoom out according to player speed

# Player movement
const MAX_JUMPS = 5
const START_SPEED = 400
const TOP_SPEED = 2000
const ACCELERATION = 3000
const FLOOR_DEACCELERATION = 7000
const AIR_DEACCELERATION = 1000
const JUMP_VELOCITY = -2400
const ROLL_VELOCITY = 1600
const GRAVITY = 4000
