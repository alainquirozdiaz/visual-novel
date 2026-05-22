extends Node

## Diccionario de tweens activos, con claves "hl_<id>" y "slide_<id>"
## para que highlight y slide_in no se cancelen mutuamente.
var _tweens: Dictionary = {}

@onready var _sprite_left: TextureRect  = get_parent().get_node("SpriteLeft")
@onready var _sprite_right: TextureRect = get_parent().get_node("SpriteRight")


func _ready() -> void:
	# Centrar el pivot para que el escalado sea desde el centro del sprite.
	_sprite_left.pivot_offset  = _sprite_left.size  / 2.0
	_sprite_right.pivot_offset = _sprite_right.size / 2.0


# ─────────────────────────────────────────────────────────────────────────────
# API pública
# ─────────────────────────────────────────────────────────────────────────────

## Resalta al personaje que habla y oscurece al inactivo.
func highlight(speaker: String) -> void:
	_animate(_sprite_left,  speaker == "left")
	_animate(_sprite_right, speaker == "right")


## Desliza un sprite desde fuera de pantalla hasta su posición original.
## Llamado automáticamente la primera vez que aparece cada sprite.
func slide_in(sprite: TextureRect, from_left: bool) -> void:
	var target_x: float = sprite.position.x
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

func _animate(sprite: TextureRect, active: bool) -> void:
	var key := "hl_" + str(sprite.get_instance_id())
	_kill_tween(key)

	var tween := create_tween().set_parallel(true)
	_tweens[key] = tween

	if active:
		tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
		tween.tween_property(sprite, "scale",    Vector2(1.03, 1.03),        0.2)
	else:
		tween.tween_property(sprite, "modulate", Color(0.5, 0.5, 0.6, 1.0), 0.2)
		tween.tween_property(sprite, "scale",    Vector2(0.97, 0.97),        0.2)


func _kill_tween(key: String) -> void:
	if _tweens.has(key) and is_instance_valid(_tweens[key]):
		_tweens[key].kill()
	_tweens.erase(key)
