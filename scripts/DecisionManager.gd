extends Node

signal option_selected(next_id: String)

@onready var _root: Control               = $DecisionRoot
@onready var _decision_box: VBoxContainer = $DecisionRoot/Panel/DecisionBox


func _ready() -> void:
	_root.visible = false


## Genera botones dinámicamente a partir del array de opciones del JSON.
func show_options(options: Array) -> void:
	# Limpiar opciones anteriores
	for child in _decision_box.get_children():
		child.queue_free()

	for option in options:
		var btn                   := Button.new()
		btn.text                   = option.get("text", "???")
		btn.custom_minimum_size    = Vector2(0, 52)
		btn.size_flags_horizontal  = Control.SIZE_EXPAND_FILL
		var next_id: String        = option.get("next", "")
		btn.pressed.connect(_on_option_pressed.bind(next_id))
		_decision_box.add_child(btn)

	_root.visible = true
	_animate_in()


func hide_options() -> void:
	_root.visible = false
	for child in _decision_box.get_children():
		child.queue_free()


## Pequeña animación de aparición: fundido + leve deslizamiento hacia arriba.
func _animate_in() -> void:
	var panel: Panel = _root.get_node("Panel")
	_root.modulate.a = 0.0
	var base_y: float = panel.position.y
	panel.position.y = base_y + 16.0

	var tween := create_tween().set_parallel(true)
	tween.tween_property(_root, "modulate:a", 1.0, 0.25)
	tween.tween_property(panel, "position:y", base_y, 0.3) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _on_option_pressed(next_id: String) -> void:
	hide_options()
	option_selected.emit(next_id)
