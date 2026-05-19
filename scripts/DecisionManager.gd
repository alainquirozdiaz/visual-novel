extends Node

signal option_selected(next_id: String)

@onready var _decision_box: VBoxContainer = $DecisionBox


func _ready() -> void:
	_decision_box.visible = false


## Genera botones dinámicamente a partir del array de opciones del JSON.
func show_options(options: Array) -> void:
	# Limpiar opciones anteriores
	for child in _decision_box.get_children():
		child.queue_free()

	for option in options:
		var btn                   := Button.new()
		btn.text                   = option.get("text", "???")
		btn.custom_minimum_size    = Vector2(0, 48)
		btn.size_flags_horizontal  = Control.SIZE_EXPAND_FILL
		var next_id: String        = option.get("next", "")
		btn.pressed.connect(_on_option_pressed.bind(next_id))
		_decision_box.add_child(btn)

	_decision_box.visible = true


func hide_options() -> void:
	_decision_box.visible = false
	for child in _decision_box.get_children():
		child.queue_free()


func _on_option_pressed(next_id: String) -> void:
	hide_options()
	option_selected.emit(next_id)
