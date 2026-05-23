extends Node

## Tweens activos por clave:
##   "float_<id>"    → flotación en bucle del personaje activo
##   "modulate_<id>" → cambio de color / opacidad
##   "slide_<id>"    → entrada desde fuera de pantalla
var _tweens: Dictionary = {}

## Estado base de cada sprite (guardado la primera vez que aparece).
var _original_positions: Dictionary = {}
var _original_scales: Dictionary    = {}

@onready var _sprite_left: TextureRect  = get_parent().get_node("SpriteLeft")
@onready var _sprite_right: TextureRect = get_parent().get_node("SpriteRight")


func _ready() -> void:
	_sprite_left.pivot_offset  = _sprite_left.size  / 2.0
	_sprite_right.pivot_offset = _sprite_right.size / 2.0


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
	# Guardar estado base ANTES de moverlo
	if not _original_positions.has(sprite):
		_original_positions[sprite] = sprite.position
	if not _original_scales.has(sprite):
		_original_scales[sprite] = sprite.scale

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
		_tween_modulate_and_scale(sprite, Color(0.5, 0.5, 0.6, 1.0), Vector2(0.97, 0.97))


## Inicia la animación de flotación en bucle (basada en el ejemplo del usuario).
##
## CORRECCIÓN vs el ejemplo original:
##   La Fase 2 usa tween_property() SIN .parallel() para que empiece
##   DESPUÉS de la Fase 1 (no en paralelo con ella).
##   La Fase 1 y Fase 2 usan .parallel() solo para mover Y y Scale
##   simultáneamente dentro de cada fase.
func _start_float(sprite: TextureRect) -> void:
	var key := "float_" + str(sprite.get_instance_id())

	# Si ya está flotando no reiniciar — evita saltos visuales
	if _tweens.has(key) and is_instance_valid(_tweens[key]) \
			and _tweens[key].is_running():
		return

	_kill_tween(key)

	# Guardar estado base si todavía no existe
	if not _original_positions.has(sprite):
		_original_positions[sprite] = sprite.position
	if not _original_scales.has(sprite):
		_original_scales[sprite] = sprite.scale

	var orig_y: float       = _original_positions[sprite].y
	var orig_scale: Vector2 = _original_scales[sprite]

	# Restaurar solo Y (X la maneja slide_in en su propio eje)
	sprite.position.y = orig_y
	sprite.scale      = orig_scale

	var tween := create_tween()
	tween.set_loops()
	_tweens[key] = tween

	# ── Fase 1: subir 8 px + escalar a 1.03× ─────────────────────────────
	tween.tween_property(sprite, "position:y", orig_y - 8.0, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(sprite, "scale", orig_scale * 1.03, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# ── Fase 2: volver a posición y escala original ───────────────────────
	# tween_property() SIN .parallel() → empieza DESPUÉS de que termine Fase 1
	tween.tween_property(sprite, "position:y", orig_y, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(sprite, "scale", orig_scale, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Detiene la flotación y restaura posición/escala base instantáneamente.
func _stop_float(sprite: TextureRect) -> void:
	var key := "float_" + str(sprite.get_instance_id())
	_kill_tween(key)

	if _original_positions.has(sprite):
		sprite.position.y = _original_positions[sprite].y
	if _original_scales.has(sprite):
		sprite.scale = _original_scales[sprite]


func _tween_modulate(sprite: TextureRect, target: Color) -> void:
	var key := "modulate_" + str(sprite.get_instance_id())
	_kill_tween(key)
	var tween := create_tween()
	_tweens[key] = tween
	tween.tween_property(sprite, "modulate", target, 0.2)


func _tween_modulate_and_scale(sprite: TextureRect, col: Color, sc: Vector2) -> void:
	var key := "modulate_" + str(sprite.get_instance_id())
	_kill_tween(key)
	var tween := create_tween().set_parallel(true)
	_tweens[key] = tween
	tween.tween_property(sprite, "modulate", col, 0.2)
	tween.tween_property(sprite, "scale",    sc,  0.2)


func _kill_tween(key: String) -> void:
	if _tweens.has(key) and is_instance_valid(_tweens[key]):
		_tweens[key].kill()
	_tweens.erase(key)
