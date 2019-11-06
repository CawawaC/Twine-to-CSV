extends FileDialog

onready var trigger_button = $"../ui/open"

func open():
	popup()

func close():
	hide()


func _on_open_dialogue_file_selected(path):
	trigger_button.text = path
