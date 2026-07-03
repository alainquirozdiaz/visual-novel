extends Node

## Tweens activos por clave:
##   "float_<id>"    → flotación vertical en bucle del personaje activo
##   "modulate_<id>" → cambio de color / opacidad (brillo del que habla)
##   "slide_<id>"    → entrada desde fuera de pantalla
var _tweens: Dictionary = {}

## Posición base de cada sprite (guardada la primera vez que aparece).
var _original_positions: Dictionary = {}

## Parámetros de la flotación — leve pero fluida y continua.
const FLOAT_AMPLITUDE: float = 6.0   # px que baja/sube respecto a su base
const FLOAT_PERIOD:    float = 2.8   # segundos por ciclo completo (sube y baja)

@onready var _sprite_left: TextureRect  = get_parent().get_node("SpriteLeft")
@onready var _sprite_right: TextureRect = get_parent().get_node("SpriteRight")


# ─────────────────────────────────────────────────────────────────────────────
# API pública
# ─────────────────────────────────────────────────────────────────────────────

## Activa flotación + brillo en el personaje que habla; apaga al inactivo.
func highlight(speaker: String) -> void:
	_set_speaker(_sprite_left,  speaker == "left")
	_set_speaker(_sprite_right, speaker == "right")


## Desliza un sprite desde fuera de pantalla hasta su posición original.
## Llamado automáticamente la primera vez que aparece cada sprite.
func slide_in(sprite: TextureRect, from_left: bool) -> void:
	if not _original_positions.has(sprite):
		_original_positions[sprite] = sprite.position

	var target_x: float = _original_positions[sprite].x
	var start_x: float  = -sprite.size.x if from_left else 1280.0 + sprite.size.x
	sprite.position.x   = start_x

	var key := "slide_" + str(sprite.get_instance_id())
	_kill_tween(key)

	var tween := create_tween()
	_tweens[key] = tween
	tween.tween_property(sprite, "position:x", target_x, 0.55) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)


# ─────────────────────────────────────────────────────────────────────────────
# Internos
# ─────────────────────────────────────────────────────────────────────────────

func _set_speaker(sprite: TextureRect, active: bool) -> void:
	if active:
		_start_float(sprite)
		_tween_modulate(sprite, Color(1.0, 1.0, 1.0, 1.0))
	else:
		_stop_float(sprite)
		_tween_modulate(sprite, Color(0.55, 0.55, 0.62, 1.0))


## Flotación vertical continua en bucle mediante una onda seno.
## Al recorrer la fase 0 → TAU a velocidad constante (LINEAR) el movimiento
## es totalmente fluido, sin pausas en los extremos. Solo mueve el eje Y.
func _start_float(sprite: TextureRect) -> void:
	var key := "float_" + str(sprite.get_instance_id())

	# Si ya está flotando no reiniciar — evita saltos visuales.
	if _tweens.has(key) and is_instance_valid(_tweens[key]) \
			and _tweens[key].is_running():
		return

	_kill_tween(key)

	if not _original_positions.has(sprite):
		_original_positions[sprite] = sprite.position

	var orig_y: float = _original_positions[sprite].y
	sprite.position.y = orig_y

	var float_method := func(phase: float) -> void:
		sprite.position.y = orig_y + sin(phase) * FLOAT_AMPLITUDE

	var tween := create_tween().set_loops()
	_tweens[key] = tween
	tween.tween_method(float_method, 0.0, TAU, FLOAT_PERIOD) \
		.set_trans(Tween.TRANS_LINEAR)


## Detiene la flotación y restaura la posición Y base instantáneamente.
func _stop_float(sprite: TextureRect) -> void:
	var key := "float_" + str(sprite.get_instance_id())
	_kill_tween(key)
	if _original_positions.has(sprite):
		sprite.position.y = _original_positions[sprite].y


func _tween_modulate(sprite: TextureRect, target: Color) -> void:
	var key := "modulate_" + str(sprite.get_instance_id())
	_kill_tween(key)
	var tween := create_tween()
	_tweens[key] = tween
	tween.tween_property(sprite, "modulate", target, 0.25)


func _kill_tween(key: String) -> void:
	if _tweens.has(key) and is_instance_valid(_tweens[key]):
		_tweens[key].kill()
	_tweens.erase(key)
