extends CanvasLayer

signal option_selected(next_id: String)

@onready var left_box: Panel       = $LeftDialogueBox
@onready var right_box: Panel      = $RightDialogueBox
@onready var narrative_box: Panel  = $NarrativeDialogueBox
@onready var decision_manager: Node = $DecisionManager


func _ready() -> void:
	hide_all_dialogue_boxes()
	decision_manager.option_selected.connect(_on_option_selected)


## Muestra la caja correcta según el speaker y devuelve el Label donde tipear.
func show_dialogue(line_data: Dictionary) -> Label:
	hide_all_dialogue_boxes()
	var speaker: String    = line_data.get("speaker", "left")
	var name_text: String  = line_data.get("name", "")

	match speaker:
		"left":
			left_box.visible = true
			left_box.get_node("NameLabel").text = name_text
			return left_box.get_node("DialogueLabel")
		"right":
			right_box.visible = true
			right_box.get_node("NameLabel").text = name_text
			return right_box.get_node("DialogueLabel")
		"narrator":
			narrative_box.visible = true
			return narrative_box.get_node("DialogueLabel")
		_:
			left_box.visible = true
			left_box.get_node("NameLabel").text = name_text
			return left_box.get_node("DialogueLabel")


func hide_all_dialogue_boxes() -> void:
	left_box.visible      = false
	right_box.visible     = false
	narrative_box.visible = false


func show_decisions(options: Array) -> void:
	decision_manager.show_options(options)


func hide_decisions() -> void:
	decision_manager.hide_options()


func _on_option_selected(next_id: String) -> void:
	option_selected.emit(next_id)
