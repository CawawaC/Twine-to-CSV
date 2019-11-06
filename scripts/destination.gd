extends FileDialog

onready var trigger_button = $"../ui/destination browse"

func open():
	popup()

func _on_destination_dir_selected(dir):
	trigger_button.text = dir
