extends Node

func _ready():
	# Remember to set as global
	Global.Constants = self

const FOLLOWERS = ['Daisy', 'Gertrud', 'Otto']

# World
const GRAVITY := 6500.0

# Player stats
const HEALTH := 5

# Player movement
const MAX_JUMPS := 2
const START_SPEED := 400.0
const TOP_SPEED := 2000.0
const ACCELERATION := 3000.0
const FLOOR_DEACCELERATION := 7000.0 # x component deacceleration when touching floor
const AIR_DEACCELERATION := 1000.0 # x component deacceleration in the air
const JUMP_VELOCITY := 2800.0
const ROLL_VELOCITY := 1200.0
const FASTFALL_VELOCITY := 1500.0
const FASTFALL_INITIAL_VELOCITY := 800.0
const FLASH_FREQUENCY := 5.0

# Camera follow configuration
const FOLLOW_X_INTERPOLATION_SPEED = 8.5 # lerp weight
const FOLLOW_Y_INTERPOLATION_SPEED = 85 # lerp weight
const CAMERA_Y_FLOOR = 0 # px
const CAMERA_ZOOM_CLOSEST = 0.4 # coeff of furthest we are zoomed in
const CAMERA_ZOOM_FURTHEST = 0.05 # coeff of furthest we can zoom out
const CAMERA_ZOOM_PLAYER_SPEED_COEFF = 0.0001 # how fast should we zoom out according to player speed
