extends Area

# Math operation for this obstacle
export var operation: String = "+"  # +, -, *, /
export var value: int = 1

# Visual feedback
var hit: bool = false
var label_text: String = ""

func _ready():
	# Set collision layers
	collision_layer = Constants.LAYER_OBSTACLES
	collision_mask = Constants.LAYER_PLAYER

	# Update label
	update_label()

	# Setup text display after being added to tree
	call_deferred("setup_text_display")

func set_operation(op: String, val: int):
	operation = op
	value = val
	update_label()

	# Setup text display after changes
	if is_inside_tree():
		call_deferred("setup_text_display")

func update_label():
	# Create label text based on operation
	label_text = "%s%d" % [operation, value]
	print("Obstacle created: ", label_text)

func setup_text_display():
	# Get the viewport and label nodes
	var viewport = get_node_or_null("TextDisplay/Viewport")
	var label = get_node_or_null("TextDisplay/Viewport/Label")
	var text_mesh = get_node_or_null("TextDisplay/TextMesh")

	if not viewport or not label or not text_mesh:
		return

	# Set the label text
	label.text = label_text

	# Create and configure a large dynamic font
	var dynamic_font = DynamicFont.new()
	var font_data = DynamicFontData.new()

	# Try to load a system font, fallback if it doesn't exist
	var font_paths = [
		"/System/Library/Fonts/Helvetica.ttc",
		"/System/Library/Fonts/Supplemental/Arial.ttf",
		"res://icon.png"  # Fallback - will fail gracefully
	]

	for font_path in font_paths:
		var file = File.new()
		if file.file_exists(font_path):
			font_data.font_path = font_path
			break

	dynamic_font.font_data = font_data
	dynamic_font.size = 300
	label.add_font_override("font", dynamic_font)

	# Make the text mesh bigger (3 units wide x 1.5 units tall)
	var quad_mesh = text_mesh.mesh as QuadMesh
	if quad_mesh:
		quad_mesh.size = Vector2(3, 1.5)

	# Wait a frame for the viewport to render
	yield(get_tree(), "idle_frame")

	# Apply the viewport texture to the text mesh
	var viewport_texture = viewport.get_texture()
	var material = SpatialMaterial.new()
	material.albedo_texture = viewport_texture
	material.flags_transparent = false
	material.flags_unshaded = true
	material.params_billboard_mode = SpatialMaterial.BILLBOARD_ENABLED
	material.params_cull_mode = SpatialMaterial.CULL_DISABLED
	text_mesh.material_override = material

func _on_body_entered(body):
	print("Obstacle: body_entered signal fired! Body: ", body.name, " Groups: ", body.get_groups())

	if hit:
		print("Obstacle: Already hit, ignoring")
		return

	if body.is_in_group("player") or body.name == "HedgehogGroup":
		print("Obstacle: Player detected! Applying operation: ", label_text)
		hit_by_player()
	else:
		print("Obstacle: Body is not player")

func hit_by_player():
	if hit:
		return

	hit = true

	# Apply the math operation to the hedgehog count
	ScoreManager.apply_math_operation(operation, value)

	# Visual feedback - flash the gate yellow
	flash_gate()

	# Remove the obstacle after a short delay
	yield(get_tree().create_timer(0.2), "timeout")
	queue_free()

func flash_gate():
	# Flash all gate parts yellow
	var gate_parts = ["Gate/LeftPillar", "Gate/RightPillar", "Gate/TopBar"]
	for part_path in gate_parts:
		var mesh_instance = get_node_or_null(part_path)
		if mesh_instance and mesh_instance.get_surface_material(0):
			var mat = mesh_instance.get_surface_material(0).duplicate()
			mat.albedo_color = Color(1, 1, 0)
			mat.emission = Color(1, 1, 0)
			mat.emission_energy = 1.0
			mesh_instance.set_surface_material(0, mat)

func get_operation_string() -> String:
	return label_text
