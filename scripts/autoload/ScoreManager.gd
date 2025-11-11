extends Node

# Scoring signals
signal score_changed(new_score)
signal distance_changed(new_distance)
signal hedgehog_count_changed(new_count, breakdown)
signal high_score_beaten(new_high_score)

# Current game stats
var current_score: int = 0
var distance_traveled: float = 0.0
var hedgehog_count: int = 1 # Start with 1 hedgehog

# Hedgehog magnitude breakdown (for color representation)
# breakdown[0] = ones, breakdown[1] = tens, breakdown[2] = hundreds, etc.
var hedgehog_breakdown: Array = [1, 0, 0, 0]

# High scores
var high_score: int = 0
var longest_distance: float = 0.0
var max_hedgehogs: int = 1

# Score values
const COLLECTIBLE_VALUE: int = 10
const DISTANCE_MULTIPLIER: float = 1.0

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	load_high_scores()

func reset_score() -> void:
	current_score = 0
	distance_traveled = 0.0
	hedgehog_count = 1
	update_hedgehog_breakdown()
	emit_signal("score_changed", current_score)
	emit_signal("distance_changed", distance_traveled)
	emit_signal("hedgehog_count_changed", hedgehog_count, hedgehog_breakdown)

func add_score(points: int) -> void:
	current_score += points
	emit_signal("score_changed", current_score)

	if current_score > high_score:
		high_score = current_score
		emit_signal("high_score_beaten", high_score)

func add_distance(delta_distance: float) -> void:
	distance_traveled += delta_distance
	# Add score based on distance traveled
	current_score += int(delta_distance * DISTANCE_MULTIPLIER)

	emit_signal("distance_changed", distance_traveled)
	emit_signal("score_changed", current_score)

	if distance_traveled > longest_distance:
		longest_distance = distance_traveled

func apply_math_operation(operation: String, value: int) -> void:
	var old_count = hedgehog_count

	match operation:
		"+":
			hedgehog_count += value
		"-":
			hedgehog_count -= value
		"*", "×":
			hedgehog_count *= value
		"/", "÷":
			if value != 0:
				hedgehog_count = int(hedgehog_count / value)

	# Ensure hedgehog count doesn't go below 0
	hedgehog_count = max(0, hedgehog_count)

	# Update the magnitude breakdown
	update_hedgehog_breakdown()

	# Track maximum hedgehogs
	if hedgehog_count > max_hedgehogs:
		max_hedgehogs = hedgehog_count

	emit_signal("hedgehog_count_changed", hedgehog_count, hedgehog_breakdown)

	print("Math operation: %s%d | %d -> %d" % [operation, value, old_count, hedgehog_count])

func update_hedgehog_breakdown() -> void:
	# Break down the hedgehog count into magnitudes
	# breakdown[0] = ones, [1] = tens, [2] = hundreds, [3] = thousands
	hedgehog_breakdown = [0, 0, 0, 0]

	var remaining = hedgehog_count
	var magnitude = 3

	while magnitude >= 0 and remaining > 0:
		var divisor = int(pow(10, magnitude))
		if remaining >= divisor:
			hedgehog_breakdown[magnitude] = int(remaining / divisor)
			remaining = remaining % divisor
		magnitude -= 1

func get_hedgehog_breakdown() -> Array:
	return hedgehog_breakdown

func collect_item(value: int = COLLECTIBLE_VALUE) -> void:
	add_score(value)

func load_high_scores() -> void:
	var save_data = StorageManager.load_game_data()
	if save_data:
		high_score = save_data.get("high_score", 0)
		longest_distance = save_data.get("longest_distance", 0.0)
		max_hedgehogs = save_data.get("max_hedgehogs", 1)

func get_save_data() -> Dictionary:
	return {
		"high_score": high_score,
		"longest_distance": longest_distance,
		"max_hedgehogs": max_hedgehogs,
		"current_score": current_score,
		"distance_traveled": distance_traveled,
		"hedgehog_count": hedgehog_count
	}
