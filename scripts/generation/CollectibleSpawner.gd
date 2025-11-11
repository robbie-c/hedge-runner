extends Spatial

# Collectible spawning settings
export var collectible_scene: PackedScene
export var spawn_chance: float = 0.3
export var spawn_interval: float = 10.0

# References
var player: KinematicBody = null
var last_spawn_z: float = 0.0

# Active collectibles
var active_collectibles: Array = []

func _ready():
	randomize()

func set_player(player_node: KinematicBody):
	player = player_node
	last_spawn_z = player.translation.z

func _process(delta):
	if not player or GameManager.current_state != GameManager.GameState.RUNNING:
		return

	update_collectible_spawning()
	cleanup_old_collectibles()

func update_collectible_spawning():
	var player_z = player.translation.z

	# Check if it's time to potentially spawn a collectible
	if last_spawn_z - player_z >= spawn_interval:
		if randf() < spawn_chance:
			spawn_collectible_set()

		last_spawn_z = player_z

func spawn_collectible_set():
	# Spawn a line of collectibles across one or more lanes
	var pattern = randi() % 3

	match pattern:
		0:  # Single lane
			spawn_collectible_in_lane(randi() % 3)
		1:  # Two lanes
			var lanes = [0, 1, 2]
			lanes.shuffle()
			spawn_collectible_in_lane(lanes[0])
			spawn_collectible_in_lane(lanes[1])
		2:  # All three lanes
			for lane in range(3):
				spawn_collectible_in_lane(lane)

func spawn_collectible_in_lane(lane: int):
	var collectible = create_collectible()

	if not collectible:
		return

	# Position the collectible
	var x_pos = Constants.get_lane_position(lane)
	var z_pos = player.translation.z - 50.0  # Spawn ahead of player
	collectible.translation = Vector3(x_pos, 1.0, z_pos)

	# Add to scene
	add_child(collectible)
	active_collectibles.append(collectible)

func create_collectible() -> Area:
	if collectible_scene:
		var collectible = collectible_scene.instance() as Area
		return collectible

	# Fallback: create a basic collectible
	return create_default_collectible()

func create_default_collectible() -> Area:
	var collectible_script = load("res://scripts/collectibles/Collectible.gd")

	var collectible = Area.new()
	collectible.set_script(collectible_script)
	collectible.add_to_group("collectible")

	# Add mesh (torus shape)
	var mesh_instance = MeshInstance.new()
	var torus_mesh = TorusMesh.new()
	torus_mesh.inner_radius = 0.3
	torus_mesh.outer_radius = 0.5
	mesh_instance.mesh = torus_mesh

	var material = SpatialMaterial.new()
	material.albedo_color = Color(1, 0.8, 0)
	material.emission_enabled = true
	material.emission = Color(1, 0.8, 0)
	material.emission_energy = 0.5
	mesh_instance.set_surface_material(0, material)

	# Rotate to stand upright
	mesh_instance.rotation_degrees = Vector3(-90, 0, 0)

	collectible.add_child(mesh_instance)

	# Add collision shape
	var collision_shape = CollisionShape.new()
	var cylinder_shape = CylinderShape.new()
	cylinder_shape.radius = 0.5
	cylinder_shape.height = 0.2
	collision_shape.shape = cylinder_shape

	collectible.add_child(collision_shape)

	# Set collision layers
	collectible.collision_layer = Constants.LAYER_COLLECTIBLES
	collectible.collision_mask = Constants.LAYER_PLAYER

	return collectible

func cleanup_old_collectibles():
	if not player:
		return

	var collectibles_to_remove = []

	for collectible in active_collectibles:
		if not is_instance_valid(collectible):
			collectibles_to_remove.append(collectible)
			continue

		var distance = collectible.translation.z - player.translation.z
		if distance > Constants.OBSTACLE_DESPAWN_DISTANCE:
			collectibles_to_remove.append(collectible)

	for collectible in collectibles_to_remove:
		active_collectibles.erase(collectible)
		if is_instance_valid(collectible):
			collectible.queue_free()

func reset():
	# Clear all collectibles
	for collectible in active_collectibles:
		if is_instance_valid(collectible):
			collectible.queue_free()

	active_collectibles.clear()
	last_spawn_z = 0.0
