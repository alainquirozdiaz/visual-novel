extends Control

## Selector de ranuras reutilizable en dos modos:
##   "save" → guardar en la ranura elegida (ranuras manuales).
##   "load" → cargar la ranura elegida (incluye autoguardado; vacías deshabilitadas).
## Cada ranura ocupada muestra un botón 🗑 para eliminarla (con confirmación).
## Emite slot_selected(slot_name) al elegir y se cierra solo.

signal slot_selected(slot_name: String)
signal closed

@onready var _title: Label            = $Panel/Title
@onready var _list: VBoxContainer     = $Panel/SlotList
@onready var _confirm: ConfirmationDialog = $ConfirmDelete

var _mode: String = "save"
var _pending_delete: String = ""


func _ready() -> void:
	visible = false
	_confirm.confirmed.connect(_on_confirm_delete)


func open(mode: String) -> void:
	_mode        = mode
	_title.text  = "Guardar partida" if mode == "save" else "Cargar partida"
	_build_slots()

	visible = true
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.2)


func close() -> void:
	visible = false
	closed.emit()


func _build_slots() -> void:
	for child in _list.get_children():
		child.queue_free()

	var slots: Array = SaveManager.manual_slots()
	# El autoguardado solo tiene sentido para cargar.
	if _mode == "load":
		slots = [SaveManager.AUTOSAVE] + slots

	var idx: int = 1
	for slot_name in slots:
		var is_auto: bool = slot_name == SaveManager.AUTOSAVE
		var title: String = "Autoguardado" if is_auto else "Ranura %d" % idx
		if not is_auto:
			idx += 1

		var exists: bool = SaveManager.has_slot(slot_name)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var btn := Button.new()
		btn.text                  = "%s   —   %s" % [title, SaveManager.slot_summary(slot_name)]
		btn.custom_minimum_size   = Vector2(0, 50)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment             = HORIZONTAL_ALIGNMENT_LEFT
		btn.clip_text             = true

		# En modo cargar, deshabilitar las ranuras vacías.
		if _mode == "load" and not exists:
			btn.disabled = true

		btn.pressed.connect(_on_slot_pressed.bind(slot_name))
		row.add_child(btn)

		# Botón de eliminar solo si la ranura tiene datos.
		if exists:
			var del := Button.new()
			del.text                = "🗑"
			del.custom_minimum_size = Vector2(50, 50)
			del.tooltip_text        = "Eliminar este guardado"
			del.pressed.connect(_on_delete_pressed.bind(slot_name, title))
			row.add_child(del)

		_list.add_child(row)


func _on_slot_pressed(slot_name: String) -> void:
	slot_selected.emit(slot_name)
	close()


func _on_delete_pressed(slot_name: String, title: String) -> void:
	_pending_delete       = slot_name
	_confirm.dialog_text  = "¿Eliminar \"%s\"?\nEsta acción no se puede deshacer." % title
	_confirm.popup_centered()


func _on_confirm_delete() -> void:
	if _pending_delete != "":
		SaveManager.delete_slot(_pending_delete)
		_pending_delete = ""
		_build_slots()


func _on_close_pressed() -> void:
	close()
