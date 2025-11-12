extends KinematicBody

# Export variables
export var hedgehog_scene: PackedScene
export var move_speed: float = 10.0
export var lateral_speed: float = 8.0

# Node references
onready var hedgehog_container: Spatial = $HedgehogContainer
onready var visual_container: Spatial = $VisualContainer

# Movement
var velocity: Vector3 = Vector3.ZERO
var target_x_position: float = 0.0
var current_lane: int = 1  # Start in middle lane (0, 1, or 2)

# Hedgehog tracking
var hedgehog_instances: Array = []
var current_count: int = 1
var current_breakdown: Array = [1, 0, 0, 0]  # ones, tens, hundreds, thousands

# Input
var mouse_position: Vector2 = Vector2.ZERO
var viewport_size: Vector2 = Vector2.ZERO

func _ready():
	# Get viewport size for pointer calculations
	viewport_size = get_viewport().size

	# Connect to score manager signals
	ScoreManager.connect("hedgehog_count_changed", self, "_on_hedgehog_count_changed")

	# Initialize hedgehog display
	update_hedgehog_display()

	# Set collision layer
	collision_layer = Constants.LAYER_PLAYER
	collision_mask = Constants.LAYER_OBSTACLES | Constants.LAYER_COLLECTIBLES

	# Add debug formation area visualization
	create_formation_debug_visual()

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		mouse_position = event.position

func _physics_process(delta):
	if GameManager.current_state != GameManager.GameState.RUNNING:
		return

	# Calculate target position based on pointer
	calculate_target_position()

	# Move forward automatically
	velocity.z = -move_speed

	# Move towards target X position
	var current_x = translation.x
	var diff = target_x_position - current_x
	velocity.x = clamp(diff * lateral_speed, -lateral_speed, lateral_speed)

	# Apply movement
	velocity = move_and_slide(velocity, Vector3.UP)

	# Debug: Print position and lane info every 60 frames
	if Engine.get_frames_drawn() % 60 == 0:
		var track_left = -Constants.TRACK_WIDTH / 2.0  # -6
		var track_right = Constants.TRACK_WIDTH / 2.0  # +6
		var distance_from_left = translation.x - track_left
		var distance_from_right = track_right - translation.x
		print("HedgehogGroup: x=", translation.x, " lane=", current_lane, " target_x=", target_x_position,
			  " | Track: left=", track_left, " right=", track_right,
			  " | Distance from edges: left=", distance_from_left, " right=", distance_from_right)

	# Update score distance
	ScoreManager.add_distance(move_speed * delta)

func calculate_target_position():
	if viewport_size.x == 0:
		return

	# Calculate which lane the pointer is in
	var pointer_ratio = mouse_position.x / viewport_size.x

	# Determine lane (0, 1, or 2)
	if pointer_ratio < 0.33:
		current_lane = 0
	elif pointer_ratio < 0.66:
		current_lane = 1
	else:
		current_lane = 2

	# Set target X position based on lane
	target_x_position = Constants.get_lane_position(current_lane)

func _on_hedgehog_count_changed(new_count: int, breakdown: Array):
	current_count = new_count
	current_breakdown = breakdown
	update_hedgehog_display()

	# Check for game over
	if new_count <= 0:
		GameManager.end_game()

func update_hedgehog_display():
	# Clear existing hedgehogs
	for hedgehog in hedgehog_instances:
		hedgehog.queue_free()
	hedgehog_instances.clear()

	# Create new hedgehogs based on breakdown
	var total_created = 0

	# Create hedgehogs for each magnitude
	for magnitude in range(current_breakdown.size()):
		var count = current_breakdown[magnitude]
		if count > 0:
			create_hedgehogs_for_magnitude(magnitude, count)
			total_created += count

func create_hedgehogs_for_magnitude(magnitude: int, count: int):
	var color = Constants.get_magnitude_color(magnitude)
	var max_to_show = min(count, 20)  # Limit visual display to prevent performance issues

	for i in range(max_to_show):
		if not hedgehog_scene:
			continue

		var hedgehog = hedgehog_scene.instance()
		visual_container.add_child(hedgehog)
		hedgehog_instances.append(hedgehog)

		# Position in a grid formation
		var row = int(i / Constants.HEDGEHOG_MAX_PER_ROW)
		var col = i % Constants.HEDGEHOG_MAX_PER_ROW

		# Center the formation: use (max-1)/2 to get symmetric offsets
		var x_offset = (col - (Constants.HEDGEHOG_MAX_PER_ROW - 1) / 2.0) * Constants.HEDGEHOG_SPACING
		var z_offset = row * Constants.HEDGEHOG_SPACING
		var y_offset = magnitude * 0.2  # Stack different magnitudes slightly higher

		hedgehog.translation = Vector3(x_offset, y_offset, z_offset)

		# Apply color to the hedgehog mesh
		var mesh_instance = hedgehog.get_node("MeshInstance")
		if mesh_instance:
			var material = mesh_instance.get_surface_material(0)
			if material:
				material = material.duplicate()
				material.albedo_color = color
				mesh_instance.set_surface_material(0, material)

func _on_body_entered(body):
	# Handle collisions with obstacles and collectibles
	if body.is_in_group("obstacle"):
		body.hit_by_player()
	elif body.is_in_group("collectible"):
		body.collect()

func create_formation_debug_visual():
	# Create a semi-transparent colored plane to show formation bounds
	var debug_mesh = MeshInstance.new()
	visual_container.add_child(debug_mesh)

	# Create a plane mesh sized to actual formation area
	# Formation spans from leftmost to rightmost hedgehog
	# With N hedgehogs, there are (N-1) gaps between them
	var formation_width = (Constants.HEDGEHOG_MAX_PER_ROW - 1) * Constants.HEDGEHOG_SPACING
	var formation_depth = 2.0  # Arbitrary depth for visibility
	var plane = PlaneMesh.new()
	plane.size = Vector2(formation_width, formation_depth)
	debug_mesh.mesh = plane

	# Position above ground level so it's visible
	debug_mesh.translation = Vector3(0, 0.5, formation_depth / 2.0)

	# Create semi-transparent bright cyan material
	var material = SpatialMaterial.new()
	material.albedo_color = Color(0, 1, 1, 0.6)  # Cyan with 60% opacity
	material.emission_enabled = true
	material.emission = Color(0, 1, 1)  # Cyan emission for visibility
	material.emission_energy = 0.5
	material.flags_transparent = true
	material.flags_unshaded = true
	material.params_cull_mode = SpatialMaterial.CULL_DISABLED  # Visible from both sides
	debug_mesh.material_override = material

func reset_position():
	translation = Constants.PLAYER_START_POSITION
	current_lane = 1
	target_x_position = Constants.get_lane_position(current_lane)
