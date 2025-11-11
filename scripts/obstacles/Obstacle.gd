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

func set_operation(op: String, val: int):
	operation = op
	value = val
	update_label()

func update_label():
	# Create label text based on operation
	label_text = "%s%d" % [operation, value]

	# In a full implementation, you'd update a 3D label or billboard here
	# For now, we'll just store the text
	print("Obstacle created: ", label_text)

func _on_body_entered(body):
	if hit:
		return

	if body.is_in_group("player") or body.name == "HedgehogGroup":
		hit_by_player()

func hit_by_player():
	if hit:
		return

	hit = true

	# Apply the math operation to the hedgehog count
	ScoreManager.apply_math_operation(operation, value)

	# Visual feedback - flash the mesh yellow
	var mesh_instance = get_node_or_null("MeshInstance")
	if mesh_instance and mesh_instance.get_surface_material(0):
		var mat = mesh_instance.get_surface_material(0).duplicate()
		mat.albedo_color = Color(1, 1, 0)
		mesh_instance.set_surface_material(0, mat)

	# Remove the obstacle after a short delay
	yield(get_tree().create_timer(0.2), "timeout")
	queue_free()

func get_operation_string() -> String:
	return label_text
