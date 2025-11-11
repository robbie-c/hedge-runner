extends Node

# Game constants

# Track settings
const TRACK_WIDTH: float = 12.0
const TRACK_SEGMENT_LENGTH: float = 20.0
const LANE_COUNT: int = 3
const LANE_WIDTH: float = TRACK_WIDTH / LANE_COUNT

# Player settings
const PLAYER_SPEED: float = 10.0
const PLAYER_LATERAL_SPEED: float = 8.0
const PLAYER_START_POSITION: Vector3 = Vector3(0, 0, 0)

# Hedgehog display settings
const HEDGEHOG_SPACING: float = 0.5
const HEDGEHOG_MAX_PER_ROW: int = 10
const HEDGEHOG_SCALE: float = 1.0

# Hedgehog color coding (by magnitude)
const COLOR_ONES: Color = Color(0.8, 0.6, 0.4)      # Brown - base hedgehog
const COLOR_TENS: Color = Color(0.4, 0.7, 1.0)      # Blue - 10s
const COLOR_HUNDREDS: Color = Color(0.9, 0.8, 0.2)  # Yellow - 100s
const COLOR_THOUSANDS: Color = Color(1.0, 0.3, 0.3) # Red - 1000s

# Math operation settings
const MATH_OPERATIONS: Array = ["+", "-", "*", "/"]
const OPERATION_RANGE_ADD: Vector2 = Vector2(1, 10)
const OPERATION_RANGE_SUBTRACT: Vector2 = Vector2(1, 5)
const OPERATION_RANGE_MULTIPLY: Vector2 = Vector2(2, 4)
const OPERATION_RANGE_DIVIDE: Vector2 = Vector2(2, 3)

# Obstacle spawn settings
const MIN_OBSTACLE_DISTANCE: float = 15.0
const MAX_OBSTACLE_DISTANCE: float = 30.0
const OBSTACLE_DESPAWN_DISTANCE: float = 30.0

# Collectible settings
const COLLECTIBLE_VALUE: int = 10
const COLLECTIBLE_SPAWN_CHANCE: float = 0.3

# Camera settings
const CAMERA_DISTANCE: float = 15.0
const CAMERA_HEIGHT: float = 12.0
const CAMERA_ANGLE: float = -45.0
const CAMERA_SMOOTHNESS: float = 0.1

# UI settings
const HUD_UPDATE_INTERVAL: float = 0.1

# Physics layers
const LAYER_PLAYER: int = 1
const LAYER_OBSTACLES: int = 2
const LAYER_COLLECTIBLES: int = 3
const LAYER_TRACK: int = 4

func get_lane_position(lane_index: int) -> float:
	# Returns the X position for a given lane (0, 1, or 2)
	var offset = -TRACK_WIDTH / 2.0 + LANE_WIDTH / 2.0
	return offset + (lane_index * LANE_WIDTH)

func get_random_operation() -> Dictionary:
	var operation = MATH_OPERATIONS[randi() % MATH_OPERATIONS.size()]
	var value = 0

	match operation:
		"+":
			value = int(rand_range(OPERATION_RANGE_ADD.x, OPERATION_RANGE_ADD.y))
		"-":
			value = int(rand_range(OPERATION_RANGE_SUBTRACT.x, OPERATION_RANGE_SUBTRACT.y))
		"*":
			value = int(rand_range(OPERATION_RANGE_MULTIPLY.x, OPERATION_RANGE_MULTIPLY.y))
		"/":
			value = int(rand_range(OPERATION_RANGE_DIVIDE.x, OPERATION_RANGE_DIVIDE.y))

	return {
		"operation": operation,
		"value": value
	}

func get_magnitude_color(magnitude: int) -> Color:
	match magnitude:
		0:
			return COLOR_ONES
		1:
			return COLOR_TENS
		2:
			return COLOR_HUNDREDS
		3:
			return COLOR_THOUSANDS
		_:
			return Color.white
