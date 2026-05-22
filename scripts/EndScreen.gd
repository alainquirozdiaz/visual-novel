extends CanvasLayer

# CanvasLayer NO hereda CanvasItem → no tiene 'modulate'.
# Usamos FadeRect (ColorRect) para el fade-in / fade-out.

@onready var fade_rect: ColorRect = $FadeRect


func _ready() -> void:
	visible = false


## Muestra la pantalla con fade-in desde negro.
func show_ending(title: String = "FIN", subtitle: String = "Gracias por jugar") -> void:
	$EndTitle.text    = title
	$EndSubtitle.text = subtitle
	visible           = true
	fade_rect.color.a = 1.0

	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, 1.5)


func _on_menu_button_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
