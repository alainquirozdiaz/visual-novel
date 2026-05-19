extends Node2D

@onready var background:          TextureRect  = $Background
@onready var sprite_left:         TextureRect  = $SpriteLeft
@onready var sprite_right:        TextureRect  = $SpriteRight
@onready var character_animator:  Node         = $CharacterAnimator
@onready var dialogue_manager:    Node         = $DialogueManager
@onready var typewriter_manager:  Node         = $TypewriterManager
@onready var ui_manager:          CanvasLayer  = $UIManager
@onready var next_button:         Button       = $UIManager/NextButton


func _ready() -> void:
	# Conectar señales
	next_button.pressed.connect(_on_next_button_pressed)
	dialogue_manager.line_displayed.connect(_on_line_displayed)
	dialogue_manager.decision_triggered.connect(_on_decision_triggered)
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	ui_manager.option_selected.connect(_on_decision_selected)

	# Cargar e iniciar el primer diálogo
	dialogue_manager.load_dialogue("res://dialogues/dialogue.json")
	dialogue_manager.start("start")


func _on_next_button_pressed() -> void:
	# Si el typewriter está escribiendo, saltar al final del texto
	if typewriter_manager.is_typing:
		typewriter_manager.skip()
	else:
		dialogue_manager.next()


func _on_line_displayed(line_data: Dictionary) -> void:
	var label: Label = ui_manager.show_dialogue(line_data)
	typewriter_manager.type_text(label, line_data.get("text", ""))
	character_animator.highlight(line_data.get("speaker", ""))
	next_button.visible = true

	# Cambios opcionales de fondo y sprites indicados en el JSON
	var bg: String = line_data.get("background", "")
	if bg != "":
		_change_background(bg)

	var sl: String = line_data.get("sprite_left", "")
	if sl != "":
		_change_sprite(sprite_left, sl)

	var sr: String = line_data.get("sprite_right", "")
	if sr != "":
		_change_sprite(sprite_right, sr)


func _on_decision_triggered(options: Array) -> void:
	next_button.visible = false
	ui_manager.hide_all_dialogue_boxes()
	ui_manager.show_decisions(options)


func _on_decision_selected(next_id: String) -> void:
	next_button.visible = true
	dialogue_manager.start(next_id)


func _on_dialogue_ended() -> void:
	next_button.visible = false
	ui_manager.hide_all_dialogue_boxes()


# ── Helpers ──────────────────────────────────────────────────────────────────

func _change_background(path: String) -> void:
	var tex = load(path)
	if tex:
		background.texture = tex


func _change_sprite(sprite: TextureRect, path: String) -> void:
	if path == "none":
		sprite.texture = null
		sprite.visible = false
		return
	var tex = load(path)
	if tex:
		sprite.texture  = tex
		sprite.visible  = true
