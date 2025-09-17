extends Node

func _ready():
	# Remember to set as global
	Global.Constants = self

const FOLLOWERS = ['Daisy', 'Gertrud', 'Otto']

# Camera follow
const FOLLOW_X_INTERPOLATION_SPEED = 8.5 # lerp weight
const FOLLOW_Y_INTERPOLATION_SPEED = 85 # lerp weight
const CAMERA_Y_FLOOR = 0 # px
const CAMERA_ZOOM_CLOSEST = 0.4 # coeff of furthest we are zoomed in
const CAMERA_ZOOM_FURTHEST = 0.05 # coeff of furthest we can zoom out
const CAMERA_ZOOM_PLAYER_SPEED_COEFF = 0.0001 # how fast should we zoom out according to player speed

# Player movement
const MAX_JUMPS := 5
const START_SPEED := 400.0
const TOP_SPEED := 2000.0
const ACCELERATION := 3000.0
const FLOOR_DEACCELERATION := 7000.0
const AIR_DEACCELERATION := 1000.0
const JUMP_VELOCITY := -2800.0
const ROLL_VELOCITY := 1600.0
const FASTFALL_VELOCITY := 1500.0
const FASTFALL_INITIAL_VELOCITY := 800.0
const GRAVITY := 6500.0
const FLASH_FREQUENCY := 5.0

# Enemy movement
const COW_SPEED := 400.0
const DRAGON_SPEED := 800.0
