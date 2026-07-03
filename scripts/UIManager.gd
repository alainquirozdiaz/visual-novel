extends CanvasLayer

signal option_selected(next_id: String)

## Colores por personaje. El cuadro se tiñe con estos valores en runtime.
## Se puede sobreescribir por línea con el campo "color" (hex "#rrggbb") en el JSON.
const CHARACTER_COLORS := {
	"Aiko": Color(0.86, 0.36, 0.52),  # rosa
	"Riku": Color(0.34, 0.56, 0.86),  # azul
}
const NARRATOR_COLOR := Color(0.45, 0.45, 0.52)  # gris neutro

@onready var box: Panel             = $DialogueBox
@onready var name_tag: Panel        = $DialogueBox/NameTag
@onready var name_label: Label      = $DialogueBox/NameTag/NameLabel
@onready var dialogue_label: Label  = $DialogueBox/DialogueLabel
@onready var decision_manager: Node = $DecisionManager

var _box_style: StyleBoxFlat
var _name_style: StyleBoxFlat


func _ready() -> void:
	# Duplicamos los StyleBox para poder teñirlos sin tocar el recurso base.
	_box_style  = box.get_theme_stylebox("panel").duplicate()
	_name_style = name_tag.get_theme_stylebox("panel").duplicate()
	box.add_theme_stylebox_override("panel", _box_style)
	name_tag.add_theme_stylebox_override("panel", _name_style)

	hide_all_dialogue_boxes()
	decision_manager.option_selected.connect(_on_option_selected)


## Muestra el cuadro con el color del personaje y devuelve el Label donde tipear.
func show_dialogue(line_data: Dictionary) -> Label:
	var speaker: String   = line_data.get("speaker", "narrator")
	var name_text: String = line_data.get("name", "")
	var col: Color        = _color_for(speaker, name_text, line_data)

	_apply_color(col)

	# El narrador (o líneas sin nombre) ocultan la placa del nombre.
	if speaker == "narrator" or name_text == "":
		name_tag.visible = false
	else:
		name_tag.visible  = true
		name_label.text   = name_text

	box.visible = true
	return dialogue_label


func hide_all_dialogue_boxes() -> void:
	box.visible = false


func show_decisions(options: Array) -> void:
	decision_manager.show_options(options)


func hide_decisions() -> void:
	decision_manager.hide_options()


# ─────────────────────────────────────────────────────────────────────────────
# Internos
# ─────────────────────────────────────────────────────────────────────────────

## Determina el color del personaje: campo "color" del JSON > mapa fijo > narrador.
func _color_for(speaker: String, name_text: String, line_data: Dictionary) -> Color:
	var hex: String = line_data.get("color", "")
	if hex != "":
		return Color(hex)
	if speaker == "narrator":
		return NARRATOR_COLOR
	if CHARACTER_COLORS.has(name_text):
		return CHARACTER_COLORS[name_text]
	return NARRATOR_COLOR


## Tiñe el cuadro: fondo = versión oscura del color, borde y placa = color pleno.
func _apply_color(col: Color) -> void:
	_box_style.border_color = col
	_box_style.bg_color     = Color(col.r * 0.22, col.g * 0.22, col.b * 0.26, 0.94)
	_name_style.bg_color    = col


func _on_option_selected(next_id: String) -> void:
	option_selected.emit(next_id)
