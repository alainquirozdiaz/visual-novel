extends Node

## Singleton (autoload) de guardado/carga.
## - Guardado manual en ranuras (slot_1 … slot_N).
## - Guardado automático en una ranura reservada ("autosave").
## - pending_state transporta el estado a restaurar entre escenas
##   (del menú de inicio a la escena de juego).

const SAVE_DIR:   String = "user://saves/"
const AUTOSAVE:   String = "autosave"
const NUM_SLOTS:  int    = 6

## Estado a restaurar al entrar a la escena de juego (vacío = empezar de cero).
var pending_state: Dictionary = {}


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


# ─────────────────────────────────────────────────────────────────────────────
# Rutas y listado
# ─────────────────────────────────────────────────────────────────────────────

func slot_path(slot_name: String) -> String:
	return SAVE_DIR + slot_name + ".save"


## Nombres de las ranuras manuales: ["slot_1", … , "slot_N"].
func manual_slots() -> Array:
	var out: Array = []
	for i in range(1, NUM_SLOTS + 1):
		out.append("slot_%d" % i)
	return out


func has_slot(slot_name: String) -> bool:
	return FileAccess.file_exists(slot_path(slot_name))


# ─────────────────────────────────────────────────────────────────────────────
# Guardar / cargar
# ─────────────────────────────────────────────────────────────────────────────

func save_to_slot(slot_name: String, state: Dictionary) -> bool:
	var data: Dictionary = state.duplicate(true)
	data["saved_at"] = Time.get_datetime_string_from_system(false, true)

	var file := FileAccess.open(slot_path(slot_name), FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: no se pudo escribir la ranura " + slot_name)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


func load_from_slot(slot_name: String) -> Dictionary:
	if not has_slot(slot_name):
		return {}
	var file := FileAccess.open(slot_path(slot_name), FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


func delete_slot(slot_name: String) -> void:
	if has_slot(slot_name):
		DirAccess.remove_absolute(slot_path(slot_name))


func autosave(state: Dictionary) -> void:
	save_to_slot(AUTOSAVE, state)


# ─────────────────────────────────────────────────────────────────────────────
# Utilidades de presentación
# ─────────────────────────────────────────────────────────────────────────────

## Resumen legible de una ranura para mostrar en la UI.
func slot_summary(slot_name: String) -> String:
	var s: Dictionary = load_from_slot(slot_name)
	if s.is_empty():
		return "— vacío —"
	var who:  String = s.get("label", s.get("current_id", "?"))
	var when: String = s.get("saved_at", "")
	if when == "":
		return who
	return "%s  ·  %s" % [who, when]
