extends Area

# Collectible value
export var point_value: int = 10
export var rotation_speed: float = 2.0

# State
var collected: bool = false

func _ready():
	# Set collision layers
	collision_layer = Constants.LAYER_COLLECTIBLES
	collision_mask = Constants.LAYER_PLAYER

func _process(delta):
	# Rotate the collectible for visual appeal
	rotate_y(rotation_speed * delta)

func _on_body_entered(body):
	if collected:
		return

	if body.is_in_group("player") or body.name == "HedgehogGroup":
		collect()

func collect():
	if collected:
		return

	collected = true

	# Add points to score
	ScoreManager.collect_item(point_value)

	# Visual feedback - scale up and change color
	scale = Vector3(1.5, 1.5, 1.5)

	var mesh_instance = get_node_or_null("MeshInstance")
	if mesh_instance and mesh_instance.get_surface_material(0):
		var mat = mesh_instance.get_surface_material(0).duplicate()
		mat.albedo_color = Color(1, 1, 0.5, 0.5)
		mesh_instance.set_surface_material(0, mat)

	# Remove after a short delay
	yield(get_tree().create_timer(0.2), "timeout")
	queue_free()
