class_name Building extends Node

var building_name: String
var source_id: int
var x_horizontal: int
var y_horizontal: int
var height: int

var tile_map_layer_index: int
var x_tile: int
var y_tile: int

func _init(source_id: int, x_horizontal: int, y_horizontal: int, height: int, building_name: String = "Building"):
	self.source_id = source_id
	self.x_horizontal = x_horizontal
	self.y_horizontal = y_horizontal
	self.height = height
	self.building_name = building_name

func set_x_tile(x_tile: int):
	self.x_tile = x_tile

func set_y_tile(y_tile: int):
	self.y_tile = y_tile

func set_tile_map_layer_index(tile_map_layer_index: int):
	self.tile_map_layer_index = tile_map_layer_index
	
func _to_string() -> String:
	return str(building_name) + ": tile_map_layer_index=" + str(tile_map_layer_index) + "; x_tile=" + str(x_tile) + "; y_tile=" + str(y_tile)
