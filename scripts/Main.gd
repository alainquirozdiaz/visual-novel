extends Node2D

@onready var background:          TextureRect  = $Background
@onready var sprite_left:         TextureRect  = $SpriteLeft
@onready var sprite_right:        TextureRect  = $SpriteRight
@onready var character_animator:  Node         = $CharacterAnimator
@onready var dialogue_manager:    Node         = $DialogueManager
@onready var typewriter_manager:  Node         = $TypewriterManager
@onready var ui_manager:          CanvasLayer  = $UIManager
@onready var next_button:         Button       = $UIManager/NextButton
@onready var fade_overlay:        ColorRect    = $TransitionLayer/FadeOverlay
@onready var end_screen:          CanvasLayer  = $EndScreen

## Evita lanzar slide_in más de una vez por sprite.
var _sprite_left_shown:  bool = false
var _sprite_right_shown: bool = false


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
# Handlers de señales
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
	end_screen.show_ending()


# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

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
	if not tex:
		return
	sprite.texture = tex
	sprite.visible = true

	# Slide-in la primera vez que aparece cada sprite
	if sprite == sprite_left and not _sprite_left_shown:
		_sprite_left_shown = true
		character_animator.slide_in(sprite_left, true)
	elif sprite == sprite_right and not _sprite_right_shown:
		_sprite_right_shown = true
		character_animator.slide_in(sprite_right, false)
