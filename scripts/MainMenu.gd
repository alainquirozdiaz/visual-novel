extends Node2D

@onready var credits_panel: Panel     = $UILayer/CreditsPanel
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
	credits_panel.visible = true


func _on_close_credits_pressed() -> void:
	credits_panel.visible = false
