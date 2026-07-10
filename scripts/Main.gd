extends Node2D

@onready var background:          TextureRect  = $Background
@onready var sprite_left:         TextureRect  = $SpriteLeft
@onready var sprite_right:        TextureRect  = $SpriteRight
@onready var character_animator:  Node         = $CharacterAnimator
@onready var dialogue_manager:    Node         = $DialogueManager
@onready var typewriter_manager:  Node         = $TypewriterManager
@onready var ui_manager:          CanvasLayer  = $UIManager
@onready var next_button:         Button       = $UIManager/DialogueBox/NextButton
@onready var system_menu:         Control      = $UIManager/SystemMenu
@onready var save_panel:          Control      = $UIManager/SaveSlotPanel
@onready var toast:               Label        = $UIManager/Toast
@onready var fade_overlay:        ColorRect    = $TransitionLayer/FadeOverlay
@onready var end_screen:          CanvasLayer  = $EndScreen

## Evita lanzar slide_in más de una vez por sprite.
var _sprite_left_shown:  bool = false
var _sprite_right_shown: bool = false

## Estado visual actual (para serializar el guardado).
var _current_bg:           String = ""
var _current_sprite_left:  String = ""
var _current_sprite_right: String = ""

## Modo activo del selector de ranuras: "save" o "load".
var _slot_mode: String = ""


func _ready() -> void:
	# Los sprites tienen textura placeholder solo para el editor:
	# en runtime empiezan ocultos hasta que el JSON asigne su sprite real.
	sprite_left.visible  = false
	sprite_right.visible = false

	# Conectar señales del diálogo
	next_button.pressed.connect(_on_next_button_pressed)
	dialogue_manager.line_displayed.connect(_on_line_displayed)
	dialogue_manager.decision_triggered.connect(_on_decision_triggered)
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	ui_manager.option_selected.connect(_on_decision_selected)

	# Conectar señales del menú de sistema y del selector de ranuras
	system_menu.save_requested.connect(_on_save_requested)
	system_menu.load_requested.connect(_on_load_requested)
	system_menu.menu_requested.connect(_on_menu_requested)
	save_panel.slot_selected.connect(_on_slot_selected)

	# Cargar el diálogo y empezar (desde cero o restaurando un guardado)
	dialogue_manager.load_dialogue("res://dialogues/dialogue.json")

	if not SaveManager.pending_state.is_empty():
		var state: Dictionary = SaveManager.pending_state
		SaveManager.pending_state = {}
		_restore_state(state)
	else:
		dialogue_manager.start("start")

	# Animación de entrada: fade desde negro + quitar desenfoque
	_play_intro()


# ─────────────────────────────────────────────────────────────────────────────
# Animación de inicio
# ─────────────────────────────────────────────────────────────────────────────

func _play_intro() -> void:
	fade_overlay.visible = true
	fade_overlay.color.a = 1.0

	var blur_method := func(v: float) -> void:
		if background.material:
			background.material.set_shader_parameter("blur_strength", v)

	var tween := create_tween().set_parallel(true)
	# Desvanece el negro en 1.2 s
	tween.tween_property(fade_overlay, "color:a", 0.0, 1.2)
	# Quita el blur del fondo en 1.8 s
	tween.tween_method(blur_method, 6.0, 0.0, 1.8)
	# Oculta el overlay cuando termina todo
	tween.set_parallel(false)
	tween.tween_callback(func() -> void: fade_overlay.visible = false)


# ─────────────────────────────────────────────────────────────────────────────
# Handlers del diálogo
# ─────────────────────────────────────────────────────────────────────────────

func _on_next_button_pressed() -> void:
	if typewriter_manager.is_typing:
		typewriter_manager.skip()
	else:
		dialogue_manager.next()


func _on_line_displayed(line_data: Dictionary) -> void:
	var label: Label = ui_manager.show_dialogue(line_data)
	typewriter_manager.type_text(label, line_data.get("text", ""))
	character_animator.highlight(line_data.get("speaker", ""))
	next_button.visible = true
	system_menu.set_available(true)

	var bg: String = line_data.get("background", "")
	if bg != "":
		_change_background(bg)

	var sl: String = line_data.get("sprite_left", "")
	if sl != "":
		_change_sprite(sprite_left, sl)

	var sr: String = line_data.get("sprite_right", "")
	if sr != "":
		_change_sprite(sprite_right, sr)

	SaveManager.autosave(_collect_state())


func _on_decision_triggered(options: Array) -> void:
	next_button.visible = false
	ui_manager.hide_all_dialogue_boxes()
	ui_manager.show_decisions(options)
	SaveManager.autosave(_collect_state())


func _on_decision_selected(next_id: String) -> void:
	next_button.visible = true
	dialogue_manager.start(next_id)


func _on_dialogue_ended() -> void:
	next_button.visible = false
	system_menu.set_available(false)
	ui_manager.hide_all_dialogue_boxes()
	end_screen.show_ending()


# ─────────────────────────────────────────────────────────────────────────────
# Handlers del menú de sistema / guardado
# ─────────────────────────────────────────────────────────────────────────────

func _on_save_requested() -> void:
	_slot_mode = "save"
	save_panel.open("save")


func _on_load_requested() -> void:
	_slot_mode = "load"
	save_panel.open("load")


func _on_slot_selected(slot_name: String) -> void:
	if _slot_mode == "save":
		if SaveManager.save_to_slot(slot_name, _collect_state()):
			_show_toast("Partida guardada")
	else:
		var state: Dictionary = SaveManager.load_from_slot(slot_name)
		if not state.is_empty():
			_restore_state(state)
			_show_toast("Partida cargada")


func _on_menu_requested() -> void:
	fade_overlay.visible = true
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


# ─────────────────────────────────────────────────────────────────────────────
# Estado (guardar / restaurar)
# ─────────────────────────────────────────────────────────────────────────────

func _collect_state() -> Dictionary:
	return {
		"current_id":           dialogue_manager.current_id,
		"background":           _current_bg,
		"sprite_left":          _current_sprite_left,
		"sprite_left_visible":  sprite_left.visible,
		"sprite_right":         _current_sprite_right,
		"sprite_right_visible": sprite_right.visible,
		"label":                _state_label(),
	}


## Aplica un estado guardado y reanuda el diálogo en el nodo correspondiente.
func _restore_state(state: Dictionary) -> void:
	# Por si se carga mientras hay un menú de decisión abierto.
	ui_manager.hide_decisions()

	var bg: String = state.get("background", "")
	if bg != "":
		_change_background(bg)

	_restore_sprite(sprite_left,  state.get("sprite_left", ""),
			state.get("sprite_left_visible", false), true)
	_restore_sprite(sprite_right, state.get("sprite_right", ""),
			state.get("sprite_right_visible", false), false)

	var id: String = state.get("current_id", "start")
	if id == "":
		id = "start"
	dialogue_manager.start(id)


func _restore_sprite(sprite: TextureRect, path: String, is_visible: bool, is_left: bool) -> void:
	if path != "" and is_visible:
		var tex := load(path)
		sprite.texture = tex
		sprite.visible = true
		if is_left:
			_current_sprite_left  = path
			_sprite_left_shown    = true
		else:
			_current_sprite_right = path
			_sprite_right_shown   = true
	else:
		sprite.visible = false
		if is_left:
			_sprite_left_shown  = false
		else:
			_sprite_right_shown = false


func _state_label() -> String:
	var entry: Dictionary = dialogue_manager.dialogue_data.get(dialogue_manager.current_id, {})
	var who: String = entry.get("name", "")
	if entry.get("speaker", "") == "narrator":
		who = "Narrador"
	if entry.get("type", "") == "decision":
		who = "Decisión"
	if who == "":
		who = "—"
	return "%s — %s" % [who, dialogue_manager.current_id]


# ─────────────────────────────────────────────────────────────────────────────
# Helpers visuales
# ─────────────────────────────────────────────────────────────────────────────

func _change_background(path: String) -> void:
	var tex = load(path)
	if tex:
		background.texture = tex
		_current_bg = path


func _change_sprite(sprite: TextureRect, path: String) -> void:
	if path == "none":
		sprite.texture = null
		sprite.visible = false
		if sprite == sprite_left:
			_current_sprite_left = ""
		else:
			_current_sprite_right = ""
		return

	var tex = load(path)
	if not tex:
		return
	sprite.texture = tex
	sprite.visible = true

	if sprite == sprite_left:
		_current_sprite_left = path
	else:
		_current_sprite_right = path

	# Slide-in la primera vez que aparece cada sprite
	if sprite == sprite_left and not _sprite_left_shown:
		_sprite_left_shown = true
		character_animator.slide_in(sprite_left, true)
	elif sprite == sprite_right and not _sprite_right_shown:
		_sprite_right_shown = true
		character_animator.slide_in(sprite_right, false)


func _show_toast(text: String) -> void:
	toast.text       = text
	toast.visible    = true
	toast.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(toast, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func() -> void: toast.visible = false)
