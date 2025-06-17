class_name BuildingFactory extends Node

var registry = {}

func _init() -> void:
	load_registry()

func load_registry():
	var file = FileAccess.open("res://src/model/data/building_registry.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var result = JSON.parse_string(json_text)
		if result is Dictionary:
			for key in result.keys():
				var path = result[key].get("script_path", "")
				if path != "":
					registry[key] = load(path)
		else:
			push_error("Invalid JSON structure in building_registry.json")
	else:
		push_error("Could not open building_registry.json")

func create_building(type_id: String) -> Building:
	if registry.has(type_id):
		return registry[type_id].new()
	push_error("Building type '%s' not found!" % type_id)
	return null
