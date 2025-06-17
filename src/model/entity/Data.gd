class_name Data extends Node

var container: Node2D

var ground: Ground
var procedural_ground: TileSetGeneration

var selected_building: Building
var buildings: Array[Building]

var zoom: int

func _init(container: Node2D) -> void:
	ground = Ground.new(container, [3, 5])
	procedural_ground = TileSetGeneration.new(ground)
	selected_building = null
	buildings = []
	zoom = 4
