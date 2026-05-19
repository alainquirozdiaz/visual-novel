extends Node

signal typing_finished

## true mientras se está escribiendo letra a letra
var is_typing: bool = false

var _target_label: Label = null
var _full_text: String   = ""
var _char_index: int     = 0

const DEFAULT_SPEED: float = 0.03

@onready var _timer: Timer = get_parent().get_node("TypewriterTimer")


func _ready() -> void:
	_timer.one_shot  = false
	_timer.wait_time = DEFAULT_SPEED
	_timer.timeout.connect(_on_tick)


## Inicia el efecto typewriter en un Label específico.
## speed: segundos entre cada carácter (menor = más rápido).
func type_text(label: Label, text: String, speed: float = DEFAULT_SPEED) -> void:
	_target_label    = label
	_full_text       = text
	_char_index      = 0
	is_typing        = true
	label.text       = ""
	_timer.wait_time = speed
	_timer.start()


## Salta el efecto y muestra el texto completo de inmediato.
func skip() -> void:
	if not is_typing:
		return
	_timer.stop()
	if _target_label != null:
		_target_label.text = _full_text
	_char_index = _full_text.length()
	is_typing   = false
	typing_finished.emit()


func _on_tick() -> void:
	if _target_label == null:
		_timer.stop()
		return

	if _char_index < _full_text.length():
		_char_index        += 1
		_target_label.text  = _full_text.substr(0, _char_index)
	else:
		_timer.stop()
		is_typing = false
		typing_finished.emit()
