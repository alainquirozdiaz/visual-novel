extends Node

## Almacena tweens activos para evitar conflictos al animar simultáneamente.
var _tweens: Dictionary = {}

@onready var _sprite_left: TextureRect  = get_parent().get_node("SpriteLeft")
@onready var _sprite_right: TextureRect = get_parent().get_node("SpriteRight")


func _ready() -> void:
	# Centrar el pivot para que el escalado sea desde el centro del sprite.
	_sprite_left.pivot_offset  = _sprite_left.size  / 2.0
	_sprite_right.pivot_offset = _sprite_right.size / 2.0


## Resalta al personaje que habla y oscurece al inactivo.
func highlight(speaker: String) -> void:
	_animate(_sprite_left,  speaker == "left")
	_animate(_sprite_right, speaker == "right")


func _animate(sprite: TextureRect, active: bool) -> void:
	var id := sprite.get_instance_id()

	# Cancelar tween anterior del mismo sprite si todavía corre.
	if _tweens.has(id) and is_instance_valid(_tweens[id]):
		_tweens[id].kill()

	var tween := create_tween().set_parallel(true)
	_tweens[id] = tween

	if active:
		tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
		tween.tween_property(sprite, "scale",    Vector2(1.03, 1.03),        0.2)
	else:
		tween.tween_property(sprite, "modulate", Color(0.5, 0.5, 0.6, 1.0), 0.2)
		tween.tween_property(sprite, "scale",    Vector2(0.97, 0.97),        0.2)
