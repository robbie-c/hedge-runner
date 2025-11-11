extends Spatial

# Track generation settings
export var track_segment_scene: PackedScene
export var segments_ahead: int = 5
export var segments_behind: int = 2

# Track state
var active_segments: Array = []
var segment_pool: Array = []
var current_spawn_position: float = 0.0
var player: KinematicBody = null

func _ready():
	# Generate initial track segments
	for i in range(segments_ahead + segments_behind):
		spawn_segment()

func set_player(player_node: KinematicBody):
	player = player_node

func _process(delta):
	if not player:
		return

	update_track_segments()

func update_track_segments():
	var player_z = player.translation.z

	# Check if we need to spawn new segments ahead
	var furthest_segment_z = get_furthest_segment_z()

	if furthest_segment_z > player_z - (segments_ahead * Constants.TRACK_SEGMENT_LENGTH):
		spawn_segment()

	# Remove segments that are too far behind
	remove_old_segments(player_z)

func spawn_segment():
	var segment: StaticBody = get_or_create_segment()

	# Position the segment
	segment.translation = Vector3(0, 0, current_spawn_position)
	add_child(segment)
	active_segments.append(segment)

	# Update spawn position for next segment
	current_spawn_position -= Constants.TRACK_SEGMENT_LENGTH

func get_or_create_segment() -> StaticBody:
	# Try to reuse from pool
	if segment_pool.size() > 0:
		return segment_pool.pop_back()

	# Create new segment
	if track_segment_scene:
		var segment = track_segment_scene.instance() as StaticBody
		return segment

	# Fallback: create a simple plane
	return create_default_segment()

func create_default_segment() -> StaticBody:
	var segment = StaticBody.new()

	var mesh_instance = MeshInstance.new()
	var cube_mesh = CubeMesh.new()
	cube_mesh.size = Vector3(Constants.TRACK_WIDTH, 0.2, Constants.TRACK_SEGMENT_LENGTH)
	mesh_instance.mesh = cube_mesh

	var material = SpatialMaterial.new()
	material.albedo_color = Color(0.3, 0.6, 0.3)
	mesh_instance.set_surface_material(0, material)

	segment.add_child(mesh_instance)

	var collision_shape = CollisionShape.new()
	var box_shape = BoxShape.new()
	box_shape.extents = Vector3(Constants.TRACK_WIDTH / 2.0, 0.1, Constants.TRACK_SEGMENT_LENGTH / 2.0)
	collision_shape.shape = box_shape

	segment.add_child(collision_shape)
	segment.collision_layer = Constants.LAYER_TRACK
	segment.collision_mask = 0

	return segment

func get_furthest_segment_z() -> float:
	if active_segments.size() == 0:
		return 0.0

	var furthest_z = active_segments[0].translation.z

	for segment in active_segments:
		if segment.translation.z < furthest_z:
			furthest_z = segment.translation.z

	return furthest_z

func remove_old_segments(player_z: float):
	var segments_to_remove = []

	for segment in active_segments:
		var distance_behind = segment.translation.z - player_z
		if distance_behind > Constants.OBSTACLE_DESPAWN_DISTANCE:
			segments_to_remove.append(segment)

	for segment in segments_to_remove:
		active_segments.erase(segment)
		remove_child(segment)
		segment_pool.append(segment)

func reset():
	# Clear all active segments
	for segment in active_segments:
		remove_child(segment)
		segment_pool.append(segment)

	active_segments.clear()
	current_spawn_position = 0.0

	# Regenerate initial segments
	for i in range(segments_ahead + segments_behind):
		spawn_segment()
