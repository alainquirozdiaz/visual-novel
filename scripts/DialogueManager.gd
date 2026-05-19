extends Node

signal dialogue_started
signal dialogue_ended
signal line_displayed(line_data: Dictionary)
signal decision_triggered(options: Array)

var dialogue_data: Dictionary = {}
var current_id: String = ""


func load_dialogue(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("DialogueManager: no se pudo abrir el archivo: " + path)
		return

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var err := json.parse(json_text)
	if err != OK:
		push_error("DialogueManager: error al parsear JSON — " + json.get_error_message())
		return

	dialogue_data.clear()
	for entry in json.get_data():
		dialogue_data[entry["id"]] = entry

	dialogue_started.emit()


func start(id: String) -> void:
	current_id = id
	_process_current()


func next() -> void:
	var entry: Dictionary = dialogue_data.get(current_id, {})
	if entry.is_empty():
		dialogue_ended.emit()
		return

	var next_id: String = entry.get("next", "")
	if next_id == "":
		dialogue_ended.emit()
		return

	current_id = next_id
	_process_current()


func _process_current() -> void:
	var entry: Dictionary = dialogue_data.get(current_id, {})
	if entry.is_empty():
		push_warning("DialogueManager: ID no encontrado — " + current_id)
		dialogue_ended.emit()
		return

	if entry.get("type", "dialogue") == "decision":
		decision_triggered.emit(entry.get("options", []))
	else:
		line_displayed.emit(entry)
