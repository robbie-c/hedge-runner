extends Node

const SAVE_FILE_PATH = "user://hedge_runner_save.json"
const LOCAL_STORAGE_KEY = "hedge_runner_state"

# JavaScript interface for web builds
var javascript_interface = null

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

	# Check if running in web browser
	if OS.get_name() == "HTML5":
		javascript_interface = JavaScript

func save_game_state() -> bool:
	var save_data = {
		"timestamp": OS.get_unix_time(),
		"score_data": ScoreManager.get_save_data(),
		"game_state": GameManager.get_state()
	}

	# For web builds, use local storage
	if OS.get_name() == "HTML5" and javascript_interface:
		return _save_to_local_storage(save_data)
	else:
		return _save_to_file(save_data)

func load_game_state() -> Dictionary:
	if OS.get_name() == "HTML5" and javascript_interface:
		return _load_from_local_storage()
	else:
		return _load_from_file()

func _save_to_local_storage(data: Dictionary) -> bool:
	if not javascript_interface:
		print("JavaScript interface not available")
		return false

	var json_string = JSON.print(data)

	# Call JavaScript localStorage.setItem
	var js_code = """
		localStorage.setItem('%s', '%s');
	""" % [LOCAL_STORAGE_KEY, json_string.replace("'", "\\'")]

	javascript_interface.eval(js_code)
	print("Game state saved to local storage")
	return true

func _load_from_local_storage() -> Dictionary:
	if not javascript_interface:
		print("JavaScript interface not available")
		return {}

	# Call JavaScript localStorage.getItem
	var js_code = """
		localStorage.getItem('%s') || '{}';
	""" % LOCAL_STORAGE_KEY

	var json_string = javascript_interface.eval(js_code)

	if json_string and json_string != "{}":
		var parse_result = JSON.parse(json_string)
		if parse_result.error == OK:
			print("Game state loaded from local storage")
			return parse_result.result
		else:
			print("Error parsing saved data: ", parse_result.error_string)

	return {}

func _save_to_file(data: Dictionary) -> bool:
	var file = File.new()
	var err = file.open(SAVE_FILE_PATH, File.WRITE)

	if err != OK:
		print("Error opening save file for writing: ", err)
		return false

	file.store_string(JSON.print(data))
	file.close()
	print("Game state saved to file: ", SAVE_FILE_PATH)
	return true

func _load_from_file() -> Dictionary:
	var file = File.new()

	if not file.file_exists(SAVE_FILE_PATH):
		print("No save file found")
		return {}

	var err = file.open(SAVE_FILE_PATH, File.READ)

	if err != OK:
		print("Error opening save file for reading: ", err)
		return {}

	var json_string = file.get_as_text()
	file.close()

	var parse_result = JSON.parse(json_string)
	if parse_result.error == OK:
		print("Game state loaded from file")
		return parse_result.result
	else:
		print("Error parsing saved data: ", parse_result.error_string)
		return {}

func load_game_data() -> Dictionary:
	var state = load_game_state()
	return state.get("score_data", {})

func clear_save_data() -> void:
	if OS.get_name() == "HTML5" and javascript_interface:
		var js_code = "localStorage.removeItem('%s');" % LOCAL_STORAGE_KEY
		javascript_interface.eval(js_code)
		print("Local storage cleared")
	else:
		var file = File.new()
		if file.file_exists(SAVE_FILE_PATH):
			var dir = Directory.new()
			dir.remove(SAVE_FILE_PATH)
			print("Save file deleted")
