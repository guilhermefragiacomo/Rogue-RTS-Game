class_name Ground extends Node

var tile_map_container: Node2D
var tile_map_layers: Array[TileMapLayer] = []
var ground_source_ids: Array[int] = []

func _init(tile_map_container: Node2D, ground_source_ids: Array[int]) -> void:
	self.tile_map_container = tile_map_container
	self.ground_source_ids = ground_source_ids
	
	tile_map_layers = get_all_tile_map_layers()

func get_all_tile_map_layers():
	tile_map_layers = []
	for child in tile_map_container.get_children():
		if (child is TileMapLayer):
			tile_map_layers.append(child)
	return tile_map_layers

func get_mouse_tile_coords(tile_map_layer_index: int, global_mouse_pos: Vector2i) -> Vector2i:
	return tile_map_layers[tile_map_layer_index].local_to_map(tile_map_layers[tile_map_layer_index].to_local(global_mouse_pos))
	
func find_tile_map_layer_index(global_mouse_position: Vector2i) -> int:
	var index = tile_map_layers.size()-1
	var found = false
	while (not found) && (index >= 0):
		var layer = tile_map_layers[index]
		var local_mouse_pos = layer.to_local(global_mouse_position)
		var cell_coords = layer.local_to_map(local_mouse_pos)
		
		if (tile_map_layers[index].get_cell_atlas_coords(cell_coords).x != -1):
			found = true
		else:
			index -= 1
	return index

func find_tile_map_layer_index_source_id(global_mouse_position: Vector2i, source_id: int) -> int:
	var index = tile_map_layers.size()-1
	var found = false
	while (not found) && (index >= 0):
		var layer = tile_map_layers[index]
		var local_mouse_pos = layer.to_local(global_mouse_position)
		var cell_coords = layer.local_to_map(local_mouse_pos)
		
		if (tile_map_layers[index].get_cell_atlas_coords(cell_coords).x != -1):
			if (tile_map_layers[index].get_cell_source_id(cell_coords) == source_id):
				found = true
			else:
				index -= 1
		else:
			index -= 1
	return index

func find_tile_map_layer_index_ground(global_mouse_position: Vector2i) -> int:
	var index = tile_map_layers.size()-1
	var found = false
	while (not found) && (index >= 0):
		var layer = tile_map_layers[index]
		var local_mouse_pos = layer.to_local(global_mouse_position)
		var cell_coords = layer.local_to_map(local_mouse_pos)
		
		if (tile_map_layers[index].get_cell_atlas_coords(cell_coords).x != -1):
			if (tile_map_layers[index].get_cell_source_id(cell_coords) in ground_source_ids):
				found = true
			else:
				index -= 1
		else:
			index -= 1
	return index
