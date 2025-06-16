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

func set_position(tile_map_layer_index: int, x_tile: int, y_tile: int):
	set_tile_map_layer_index(tile_map_layer_index)
	set_x_tile(x_tile)
	set_y_tile(y_tile)

static func select_building(ground: Ground, buildings : Array[Building], tile_pos: Vector2i, global_mouse_pos: Vector2i) -> Building:
	var tile_map_layer_index = ground.find_tile_map_layer_index(global_mouse_pos)
	var tile_map_layer = ground.tile_map_layers[tile_map_layer_index]
	
	var atlas_id = tile_map_layer.get_cell_atlas_coords(tile_pos)
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)
	
	print(str(tile_map_layer_index) + " : " + str(atlas_id) + " / " + str(tile_pos) + " / " + str(source_id))
	return 

func _to_string() -> String:
	return str(building_name) + ": tile_map_layer_index=" + str(tile_map_layer_index) + "; x_tile=" + str(x_tile) + "; y_tile=" + str(y_tile)

func check_if_can_build(ground: Ground, tile_pos: Vector2i, global_mouse_pos: Vector2i) -> bool:
	var tile_map_layer_index = ground.find_tile_map_layer_index_ground(global_mouse_pos)
	var tile_map_layer = ground.tile_map_layers[tile_map_layer_index]
	
	var x_index = tile_pos.x - 1
	var y_index = tile_pos.y
	
	var free_space = true
	
	if ground.tile_map_layers[tile_map_layer_index].get_cell_source_id(tile_pos) == 3:
		for y_atlas_check in range(height - 1, -1, -1):
			var y_atlas_check_temp = 0
			var x_index_temp = x_index + 1
			var y_index_temp = y_index + 1
			if (y_atlas_check == height - 1):
				for x_atlas_check in range(0, x_horizontal):
					if (ground.tile_map_layers[tile_map_layer_index].get_cell_atlas_coords(Vector2i(x_index_temp, y_index_temp)).y != 0):
						free_space = false
					y_atlas_check_temp = x_atlas_check
					for l in range(0, y_horizontal):
						y_index_temp -= 1
						y_atlas_check_temp += l + 1
						if (ground.tile_map_layers[tile_map_layer_index].get_cell_atlas_coords(Vector2i(x_index_temp, y_index_temp)).y != 0):
							free_space = false
					x_index_temp += 1
					y_index_temp += y_horizontal
			
			for x_atlas_check in range(0, x_horizontal):
				if (ground.tile_map_layers[tile_map_layer_index + 1].get_cell_atlas_coords(Vector2i(x_index, y_index)).x != -1):
					free_space = false
				y_atlas_check_temp = x_atlas_check
				for l in range(0, y_horizontal):
					y_index -= 1
					y_atlas_check_temp += l + 1
					if (ground.tile_map_layers[tile_map_layer_index + 1].get_cell_atlas_coords(Vector2i(x_index, y_index)).x != -1):
						free_space = false
				x_index += 1
				y_index += y_horizontal
			
			tile_map_layer_index += 1
			x_index -= x_horizontal + 1
			y_index -= 1
	else:
		free_space = false
	
	return free_space

func place_building(ground: Ground, tile_pos: Vector2i, global_mouse_pos: Vector2i) -> Building:	
	if (check_if_can_build(ground, tile_pos, global_mouse_pos)):
		var tile_map_layer_index = ground.find_tile_map_layer_index_ground(global_mouse_pos)
		var tile_map_layer = ground.tile_map_layers[tile_map_layer_index]
		
		var atlas_coords = tile_map_layer.get_cell_atlas_coords(tile_pos)
		var tile_set_source = source_id
				
		var x_index = tile_pos.x - 1
		var y_index = tile_pos.y
		
		var new_building = SimpleHouse.new()
		new_building.set_position(tile_map_layer_index, tile_pos.x + 1, tile_pos.y + 1);
		
		for y_atlas_place in range(height-1, -1, -1):
			var y_atlas_place_temp = 0
			for x_atlas_place in range(0, x_horizontal):
				ground.tile_map_layers[tile_map_layer_index + 1].set_cell(Vector2i(x_index, y_index), tile_set_source, Vector2i(x_atlas_place, y_atlas_place))
				x_index += 1
				y_atlas_place_temp = x_atlas_place
				
				if x_atlas_place < x_horizontal - 1:
					for g in range(0, y_horizontal):
						y_index -= 1
						ground.tile_map_layers[tile_map_layer_index + 1].set_cell(Vector2i(x_index -1, y_index), 2, Vector2i(3, 0))
					y_index += y_horizontal
			x_index -= 1
			for k in range(0, y_horizontal):
				y_index -= 1
				y_atlas_place_temp += k + 1
				ground.tile_map_layers[tile_map_layer_index + 1].set_cell(Vector2i(x_index, y_index), tile_set_source, Vector2i(y_atlas_place_temp, y_atlas_place))
			tile_map_layer_index += 1
			x_index -= x_horizontal
		return new_building
	return null
