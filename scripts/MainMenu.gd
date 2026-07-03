extends Node2D

@onready var credits_root:  Control   = $UILayer/CreditsRoot
@onready var credits_panel: Panel     = $UILayer/CreditsRoot/Panel
@onready var fade_overlay:  ColorRect = $UILayer/FadeOverlay


func _ready() -> void:
	# Empieza negro (mouse_filter=STOP para bloquear clics durante el fade inicial)
	fade_overlay.color.a    = 1.0
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween := create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 0.8)
	# Una vez transparente, dejar pasar los clics
	tween.tween_callback(
		func() -> void: fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)


func _on_start_pressed() -> void:
	# Volver a bloquear input y hacer fade a negro antes de cambiar escena
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 0.6)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_credits_pressed() -> void:
	credits_root.visible   = true
	credits_root.modulate.a = 0.0
	var base_y: float = credits_panel.position.y
	credits_panel.position.y = base_y + 20.0

	var tween := create_tween().set_parallel(true)
	tween.tween_property(credits_root, "modulate:a", 1.0, 0.25)
	tween.tween_property(credits_panel, "position:y", base_y, 0.3) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _on_close_credits_pressed() -> void:
	var base_y: float = credits_panel.position.y
	var tween := create_tween().set_parallel(true)
	tween.tween_property(credits_root, "modulate:a", 0.0, 0.2)
	tween.tween_property(credits_panel, "position:y", base_y + 20.0, 0.2) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
	credits_root.visible     = false
	credits_panel.position.y = base_y
	credits_root.modulate.a  = 1.0
