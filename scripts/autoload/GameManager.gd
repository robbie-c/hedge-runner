extends Node

# Game states
enum GameState {
	LOADING,
	READY,
	RUNNING,
	PAUSED,
	GAME_OVER,
	UNLOADING
}

# Current game state
var current_state = GameState.LOADING setget set_state, get_state

# Signals for state changes
signal state_changed(new_state, old_state)
signal game_started
signal game_paused
signal game_resumed
signal game_over
signal loading_complete

# Game settings
var game_speed: float = 10.0
var base_difficulty: float = 1.0
var difficulty_multiplier: float = 1.0

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	set_state(GameState.READY)

func set_state(new_state: int) -> void:
	var old_state = current_state
	current_state = new_state
	emit_signal("state_changed", new_state, old_state)

	match new_state:
		GameState.RUNNING:
			emit_signal("game_started")
			get_tree().paused = false
		GameState.PAUSED:
			emit_signal("game_paused")
			get_tree().paused = true
		GameState.GAME_OVER:
			emit_signal("game_over")
		GameState.LOADING:
			pass
		GameState.UNLOADING:
			_handle_unload()

func get_state() -> int:
	return current_state

func start_game() -> void:
	ScoreManager.reset_score()
	set_state(GameState.RUNNING)

func pause_game() -> void:
	if current_state == GameState.RUNNING:
		set_state(GameState.PAUSED)

func resume_game() -> void:
	if current_state == GameState.PAUSED:
		set_state(GameState.RUNNING)
		emit_signal("game_resumed")

func end_game() -> void:
	set_state(GameState.GAME_OVER)
	StorageManager.save_game_state()

func on_loading_complete() -> void:
	# Called by external query engine when loading is done
	emit_signal("loading_complete")
	StorageManager.save_game_state()
	set_state(GameState.UNLOADING)

func _handle_unload() -> void:
	# Save state immediately and prepare for unload
	StorageManager.save_game_state()
	# The game will be unloaded by the external system
	print("Game state saved, ready for unload")

func increase_difficulty(amount: float) -> void:
	difficulty_multiplier += amount
	difficulty_multiplier = clamp(difficulty_multiplier, 1.0, 5.0)
