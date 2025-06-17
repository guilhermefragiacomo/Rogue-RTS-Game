class_name BuildingPlacement extends Node

func check_if_can_build(ground: Ground, building: Building, global_mouse_pos: Vector2i) -> bool:
	var tile_pos = ground.get_tile_coords_ground(global_mouse_pos)
	
	var tile_map_layer_index = ground.find_tile_map_layer_index_ground(global_mouse_pos)
	var tile_map_layer = ground.tile_map_layers[tile_map_layer_index]
	
	var x_index = tile_pos.x - 1
	var y_index = tile_pos.y
	
	var free_space = true
	
	if ground.tile_map_layers[tile_map_layer_index].get_cell_source_id(tile_pos) == 3:
		for y_atlas_check in range(building.height - 1, -1, -1):
			var y_atlas_check_temp = 0
			var x_index_temp = x_index + 1
			var y_index_temp = y_index + 1
			if (y_atlas_check == building.height - 1):
				for x_atlas_check in range(0, building.x_horizontal):
					if (ground.tile_map_layers[tile_map_layer_index].get_cell_atlas_coords(Vector2i(x_index_temp, y_index_temp)).y != 0):
						free_space = false
					y_atlas_check_temp = x_atlas_check
					for l in range(0, building.y_horizontal):
						y_index_temp -= 1
						y_atlas_check_temp += l + 1
						if (ground.tile_map_layers[tile_map_layer_index].get_cell_atlas_coords(Vector2i(x_index_temp, y_index_temp)).y != 0):
							free_space = false
					x_index_temp += 1
					y_index_temp += building.y_horizontal
			
			for x_atlas_check in range(0, building.x_horizontal):
				if (ground.tile_map_layers[tile_map_layer_index + 1].get_cell_atlas_coords(Vector2i(x_index, y_index)).x != -1):
					free_space = false
				y_atlas_check_temp = x_atlas_check
				for l in range(0, building.y_horizontal):
					y_index -= 1
					y_atlas_check_temp += l + 1
					if (ground.tile_map_layers[tile_map_layer_index + 1].get_cell_atlas_coords(Vector2i(x_index, y_index)).x != -1):
						free_space = false
				x_index += 1
				y_index += building.y_horizontal
			
			tile_map_layer_index += 1
			x_index -= building.x_horizontal + 1
			y_index -= 1
	else:
		free_space = false
	
	return free_space

func place_building(ground: Ground, building: Building, global_mouse_pos: Vector2i) -> Building:
	var tile_pos = ground.get_tile_coords_ground(global_mouse_pos)
	if (check_if_can_build(ground, building, global_mouse_pos)):
		var tile_map_layer_index = ground.find_tile_map_layer_index_ground(global_mouse_pos)
		var tile_map_layer = ground.tile_map_layers[tile_map_layer_index]
		
		var atlas_coords = tile_map_layer.get_cell_atlas_coords(tile_pos)
		var tile_set_source = building.source_id
				
		var x_index = tile_pos.x - 1
		var y_index = tile_pos.y
		
		var new_building: Building;
		
		for y_atlas_place in range(building.height-1, -1, -1):
			var y_atlas_place_temp = 0
			for x_atlas_place in range(0, building.x_horizontal):
				ground.tile_map_layers[tile_map_layer_index + 1].set_cell(Vector2i(x_index, y_index), tile_set_source, Vector2i(x_atlas_place, y_atlas_place))
				
				if (y_atlas_place == 0):
					if (x_atlas_place == 0):
						new_building = SimpleHouse.new()
						new_building.set_position(tile_map_layer_index + 1, x_index, y_index);
						
						print(new_building)
				
				x_index += 1
				y_atlas_place_temp = x_atlas_place
				
				if x_atlas_place < building.x_horizontal - 1:
					for g in range(0, building.y_horizontal):
						y_index -= 1
						ground.tile_map_layers[tile_map_layer_index + 1].set_cell(Vector2i(x_index -1, y_index), 2, Vector2i(3, 0))
					y_index += building.y_horizontal
			x_index -= 1
			for k in range(0, building.y_horizontal):
				y_index -= 1
				y_atlas_place_temp += k + 1
				ground.tile_map_layers[tile_map_layer_index + 1].set_cell(Vector2i(x_index, y_index), tile_set_source, Vector2i(y_atlas_place_temp, y_atlas_place))
			tile_map_layer_index += 1
			x_index -= building.x_horizontal
		return new_building
	return null
