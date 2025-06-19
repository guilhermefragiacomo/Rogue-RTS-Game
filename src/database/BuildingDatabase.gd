class_name BuildingDatabase extends Node

var buildings: Array[Building]

func _init() -> void:
	buildings = []

func add_building(building: Building):
	buildings.append(building)

func remove_building(building: Building):
	buildings.erase(building)
	building.queue_free()
