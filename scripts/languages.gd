extends OptionButton

signal language_selected

func _ready():
	add_item("fr", 0)
	add_item("en", 1)
	
	select(get_item_id(0))
	
	_on_languages_item_selected(get_selected_id())

func _on_languages_item_selected(ID):
	emit_signal("language_selected", get_item_text(ID))

func get_lang():
	var text = get_item_text(get_selected_id())
	return text
