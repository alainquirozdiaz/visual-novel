extends Node2D

@onready var credits_panel: Panel    = $UILayer/CreditsPanel
@onready var fade_overlay:  ColorRect = $UILayer/FadeOverlay


func _ready() -> void:
	# Fade desde negro al entrar al menú
	fade_overlay.color.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 0.8)


func _on_start_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 0.6)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_credits_pressed() -> void:
	credits_panel.visible = true


func _on_close_credits_pressed() -> void:
	credits_panel.visible = false
