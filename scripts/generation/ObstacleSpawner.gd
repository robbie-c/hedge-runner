extends Spatial

# Obstacle spawning settings
export var obstacle_scene: PackedScene
export var min_spawn_distance: float = 15.0
export var max_spawn_distance: float = 30.0

# References
var player: KinematicBody = null
var last_spawn_z: float = 0.0
var next_spawn_distance: float = 20.0

# Active obstacles
var active_obstacles: Array = []

func _ready():
	randomize()
	calculate_next_spawn_distance()

func set_player(player_node: KinematicBody):
	player = player_node
	last_spawn_z = player.translation.z

	# Spawn test gates for debugging
	call_deferred("spawn_test_gates")

func _process(delta):
	if not player or GameManager.current_state != GameManager.GameState.RUNNING:
		return

	update_obstacle_spawning()
	cleanup_old_obstacles()

func update_obstacle_spawning():
	var player_z = player.translation.z

	# Check if it's time to spawn a new obstacle
	if last_spawn_z - player_z >= next_spawn_distance:
		spawn_obstacle_set()
		last_spawn_z = player_z
		calculate_next_spawn_distance()

func spawn_obstacle_set():
	# Decide how many lanes will have obstacles (1-2 lanes, leaving at least one clear)
	var num_obstacles = 1 + (randi() % 2)  # 1 or 2 obstacles

	var available_lanes = [0, 1, 2]
	available_lanes.shuffle()

	# Spawn obstacles in random lanes
	for i in range(num_obstacles):
		var lane = available_lanes[i]
		spawn_obstacle_in_lane(lane)

func spawn_obstacle_in_lane(lane: int):
	var obstacle = create_obstacle()

	if not obstacle:
		return

	# Position the obstacle
	var x_pos = Constants.get_lane_position(lane)
	var z_pos = player.translation.z - 50.0  # Spawn ahead of player
	obstacle.translation = Vector3(x_pos, 1.0, z_pos)

	print("ObstacleSpawner: Spawning obstacle at position: ", obstacle.translation, " Player at: ", player.translation)

	# Generate random math operation
	var math_op = Constants.get_random_operation()
	obstacle.set_operation(math_op.operation, math_op.value)

	# Add to scene
	add_child(obstacle)
	active_obstacles.append(obstacle)

	print("ObstacleSpawner: Obstacle monitoring=", obstacle.monitoring, " monitorable=", obstacle.monitorable, " layer=", obstacle.collision_layer, " mask=", obstacle.collision_mask)

func create_obstacle() -> Area:
	if obstacle_scene:
		var obstacle = obstacle_scene.instance() as Area
		return obstacle

	# Fallback: create a basic obstacle
	return create_default_obstacle()

func create_default_obstacle() -> Area:
	var obstacle_script = load("res://scripts/obstacles/Obstacle.gd")

	var obstacle = Area.new()
	obstacle.set_script(obstacle_script)
	obstacle.add_to_group("obstacle")

	# Add mesh
	var mesh_instance = MeshInstance.new()
	var cube_mesh = CubeMesh.new()
	cube_mesh.size = Vector3(2, 2, 2)
	mesh_instance.mesh = cube_mesh

	var material = SpatialMaterial.new()
	material.albedo_color = Color(0.8, 0.3, 0.3)
	mesh_instance.set_surface_material(0, material)

	obstacle.add_child(mesh_instance)

	# Add collision shape
	var collision_shape = CollisionShape.new()
	var box_shape = BoxShape.new()
	box_shape.extents = Vector3(1, 1, 1)
	collision_shape.shape = box_shape

	obstacle.add_child(collision_shape)

	# Set collision layers
	obstacle.collision_layer = Constants.LAYER_OBSTACLES
	obstacle.collision_mask = Constants.LAYER_PLAYER

	return obstacle

func cleanup_old_obstacles():
	if not player:
		return

	var obstacles_to_remove = []

	for obstacle in active_obstacles:
		if not is_instance_valid(obstacle):
			obstacles_to_remove.append(obstacle)
			continue

		var distance = obstacle.translation.z - player.translation.z
		if distance > Constants.OBSTACLE_DESPAWN_DISTANCE:
			obstacles_to_remove.append(obstacle)

	for obstacle in obstacles_to_remove:
		active_obstacles.erase(obstacle)
		if is_instance_valid(obstacle):
			obstacle.queue_free()

func calculate_next_spawn_distance():
	var base_distance = rand_range(min_spawn_distance, max_spawn_distance)
	var difficulty_factor = GameManager.difficulty_multiplier
	next_spawn_distance = base_distance / difficulty_factor
	next_spawn_distance = max(next_spawn_distance, 10.0)  # Minimum distance

func spawn_test_gates():
	# Spawn 3 gates side by side for testing (one in each lane)
	var test_z = player.translation.z - 20.0  # Close to start

	for lane in range(3):
		var obstacle = create_obstacle()
		if not obstacle:
			continue

		var x_pos = Constants.get_lane_position(lane)
		obstacle.translation = Vector3(x_pos, 1.0, test_z)

		# Set simple test operations
		var operations = ["+5", "-3", "*2"]
		var op = operations[lane][0]
		var val = int(operations[lane].substr(1))
		obstacle.set_operation(op, val)

		add_child(obstacle)
		active_obstacles.append(obstacle)
		print("Test gate spawned in lane ", lane, " at x=", x_pos)

func reset():
	# Clear all obstacles
	for obstacle in active_obstacles:
		if is_instance_valid(obstacle):
			obstacle.queue_free()

	active_obstacles.clear()
	last_spawn_z = 0.0
	calculate_next_spawn_distance()
