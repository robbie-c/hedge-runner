extends Spatial

# Scene references
onready var camera: Camera = $Camera
onready var game_world: Spatial = $GameWorld
onready var player: KinematicBody = $GameWorld/HedgehogGroup
onready var track_generator: Spatial = $GameWorld/TrackGenerator
onready var obstacle_spawner: Spatial = $GameWorld/ObstacleSpawner
onready var collectible_spawner: Spatial = $GameWorld/CollectibleSpawner

# Camera follow settings
var camera_offset: Vector3 = Vector3(0, 12, 15)
var camera_smoothness: float = 0.1

func _ready():
	# Connect to game manager signals
	GameManager.connect("game_started", self, "_on_game_started")
	GameManager.connect("game_over", self, "_on_game_over")
	GameManager.connect("loading_complete", self, "_on_loading_complete")

	# Set up the camera
	setup_camera()

	# Initialize systems
	initialize_systems()

	# Start the game automatically
	yield(get_tree().create_timer(0.5), "timeout")
	GameManager.start_game()

func initialize_systems():
	# Connect player to generators
	if track_generator and track_generator.has_method("set_player"):
		track_generator.set_player(player)

	if obstacle_spawner and obstacle_spawner.has_method("set_player"):
		obstacle_spawner.set_player(player)

	if collectible_spawner and collectible_spawner.has_method("set_player"):
		collectible_spawner.set_player(player)

func _process(delta):
	if player and GameManager.current_state == GameManager.GameState.RUNNING:
		update_camera_position(delta)

func setup_camera():
	# Position camera to look down at the track
	camera.translation = camera_offset
	camera.look_at(Vector3.ZERO, Vector3.UP)

func update_camera_position(delta):
	if not player:
		return

	# Smoothly follow the player
	var target_position = player.translation + camera_offset
	camera.translation = camera.translation.linear_interpolate(target_position, camera_smoothness)

func _on_game_started():
	print("Game started!")

func _on_game_over():
	print("Game over!")
	# Could show game over screen here

func _on_loading_complete():
	print("Loading complete - saving and unloading")
