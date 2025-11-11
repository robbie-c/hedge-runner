extends CanvasLayer

# UI element references
onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
onready var distance_label: Label = $MarginContainer/VBoxContainer/DistanceLabel
onready var hedgehog_label: Label = $MarginContainer/VBoxContainer/HedgehogLabel
onready var breakdown_label: Label = $MarginContainer/VBoxContainer/BreakdownLabel

func _ready():
	# Connect to score manager signals
	ScoreManager.connect("score_changed", self, "_on_score_changed")
	ScoreManager.connect("distance_changed", self, "_on_distance_changed")
	ScoreManager.connect("hedgehog_count_changed", self, "_on_hedgehog_count_changed")

	# Initialize display
	update_all()

func update_all():
	_on_score_changed(ScoreManager.current_score)
	_on_distance_changed(ScoreManager.distance_traveled)
	_on_hedgehog_count_changed(ScoreManager.hedgehog_count, ScoreManager.hedgehog_breakdown)

func _on_score_changed(new_score: int):
	score_label.text = "Score: %d" % new_score

func _on_distance_changed(new_distance: float):
	distance_label.text = "Distance: %dm" % int(new_distance)

func _on_hedgehog_count_changed(new_count: int, breakdown: Array):
	hedgehog_label.text = "Hedgehogs: %d" % new_count

	# Format breakdown display
	var breakdown_text = "Breakdown: "
	var parts = []

	if breakdown[3] > 0:
		parts.append("%d×1000" % breakdown[3])
	if breakdown[2] > 0:
		parts.append("%d×100" % breakdown[2])
	if breakdown[1] > 0:
		parts.append("%d×10" % breakdown[1])
	if breakdown[0] > 0:
		parts.append("%d×1" % breakdown[0])

	if parts.size() > 0:
		breakdown_text += " + ".join(parts)
	else:
		breakdown_text += "0"

	breakdown_label.text = breakdown_text
