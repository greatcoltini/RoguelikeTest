extends Node

var monster_data: Dictionary

func _ready():
	monster_data = LoadData("res://data/entities/enemies.json")
	

func LoadData(file_path):
	var json_data = JSON.new()
	var file_data = FileAccess.open(file_path, FileAccess.READ)
	
	json_data.parse(file_data.get_as_text())
	file_data.close()
	
	return json_data.get_data()
