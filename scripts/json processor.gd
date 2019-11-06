extends Control


var json_path
var lang
var csv_delimiter = ";"

var destination_path


func _ready():
	update_process_permission()
	
	lang = $ui/languages.get_lang()
	print(lang)


func process():
	var json_string = load_file(json_path)
	var json = JSON.parse(json_string).result
	
	var csv_file = File.new()
	var json_path_array = json_path.get_basename().split("/")
	var last = json_path_array[json_path_array.size()-1]
	
	var csv_path = str(destination_path, "/", last, ".csv")
	log_line("Opening .csv file at path: " + csv_path)
	csv_file.open(csv_path, File.READ)
	
	var lines_array = []
	while not csv_file.eof_reached():
		var s = csv_file.get_csv_line(csv_delimiter)
		lines_array.append(s)
	
	if lines_array.size() < 1:
		log_line("Empty file, creating header")
		lines_array.append(["id", "fr", "en"])
		
	write_csv_array(lines_array, json, last)
	write_csv(lines_array, csv_file, csv_path)
	
	var shrunk_json_file = File.new()
	var shrunk_json_path = str(destination_path, "/", last, ".json")
	shrunk_json_file.open(shrunk_json_path, File.WRITE)
	simplify_json(json, shrunk_json_file)


func find_and_change_line(lines_array, id, text):
	for line in lines_array:
		if line[0] == id:
			log_line("Existing line with id: " + id)
			if lang == "fr":
				log_line("Adding French text")
				line[1] = text
			elif lang == "en":
				log_line("Adding English text")
				line[2] = text
				
			return true
	return false

func log_line(line):
	$logbox.text += line + "\n"

func write_csv_array(lines_array, json, dialogue_name):
	lines_array = Array(lines_array)
	for x in json.passages:
		var id = str(dialogue_name, "_", x.pid)
		var text = "" + x.name + ""
		
		if !find_and_change_line(lines_array, id, text):
			# no line with given id --> new line
			log_line("New line with id: " + id)
			if lang == "fr":
				lines_array.append([id, text, ""])
			elif lang == "en":
				lines_array.append([id, "", text])

func write_csv(lines, file, path):
	file.open(path, File.WRITE)
	for line in lines:
		file.store_csv_line(line, csv_delimiter)
	log_line("======= DONE =======")

func simplify_json(json, file):
	for x in json.passages:
		x.erase("position")
		x.erase("name")
		
		if x.has("links"):
			x.erase("text")
			for y in x.links:
				y.erase("link")
	
	var shrunk_string = JSON.print(json)
	file.store_string(shrunk_string)


func load_file(path):
	var file = File.new()
	if file.open(path, file.READ) != OK:
		printerr("Failed to load: " + path)
	var content = file.get_as_text()
	file.close()
	return content

func _on_open_dialogue_file_selected(path):
	json_path = path
	update_process_permission()


func update_process_permission():
	var permit = true
	if !json_path:
		permit = false
	elif !destination_path:
		permit = false
	elif !lang:
		permit = false
		
	$ui/process.disabled = !permit

func _on_destination_dir_selected(dir):
	destination_path = dir
	update_process_permission()


func _on_languages_language_selected(_lang):
	lang = _lang
	update_process_permission()
