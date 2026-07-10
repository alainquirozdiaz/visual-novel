extends Control

## Menú de sistema in-game. Un botón "☰" lo abre; el overlay ofrece
## guardar, cargar o volver al menú principal. Emite señales que Main
## conecta para ejecutar cada acción.

signal save_requested
signal load_requested
signal menu_requested

@onready var _open_button: Button = $OpenButton
@onready var _overlay: Control    = $Overlay


func _ready() -> void:
	_overlay.visible = false


## Muestra u oculta el botón de apertura (Main lo oculta en el cierre del juego).
func set_available(v: bool) -> void:
	_open_button.visible = v


func open() -> void:
	_overlay.visible   = true
	_overlay.modulate.a = 0.0
	create_tween().tween_property(_overlay, "modulate:a", 1.0, 0.18)


func close() -> void:
	_overlay.visible = false


func _on_open_pressed() -> void:
	open()


func _on_resume_pressed() -> void:
	close()


func _on_save_pressed() -> void:
	close()
	save_requested.emit()


func _on_load_pressed() -> void:
	close()
	load_requested.emit()


func _on_menu_pressed() -> void:
	close()
	menu_requested.emit()
