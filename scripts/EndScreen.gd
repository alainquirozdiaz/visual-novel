extends CanvasLayer


func _ready() -> void:
	visible = false


## Muestra la pantalla de cierre con un fade-in.
func show_ending(title: String = "FIN", subtitle: String = "Gracias por jugar") -> void:
	$EndTitle.text    = title
	$EndSubtitle.text = subtitle
	visible           = true
	modulate.a        = 0.0

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.5)


func _on_menu_button_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
