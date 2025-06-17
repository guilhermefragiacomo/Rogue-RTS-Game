class_name BuildingSelection extends Node

func select_building(ground: Ground, buildings: Array[Building], global_mouse_pos: Vector2i) -> Building:
	var tile_pos = ground.get_tile_coords(global_mouse_pos)
	var tile_map_layer_index = ground.find_tile_map_layer_index(global_mouse_pos)
	var tile_map_layer = ground.tile_map_layers[tile_map_layer_index]
	
	var atlas_id = tile_map_layer.get_cell_atlas_coords(tile_pos)
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)
	var tile_map_layer_index_new = tile_map_layer_index + atlas_id.y
	var new_x_y = Vector2i()
	
	for b in buildings:
		if (b.source_id == source_id):
			if (b.tile_map_layer_index == tile_map_layer_index_new):
				if (atlas_id.x >= b.x_horizontal):
					new_x_y.x = tile_pos.x - b.x_horizontal + 1 - atlas_id.y
					new_x_y.y = tile_pos.y - atlas_id.y + (atlas_id.x - b.y_horizontal)
				else:
					new_x_y.x = tile_pos.x - atlas_id.x - atlas_id.y
					new_x_y.y = tile_pos.y - atlas_id.y
				if (b.x_tile == new_x_y.x):
					if (b.y_tile == new_x_y.y):
						return b
	return null
