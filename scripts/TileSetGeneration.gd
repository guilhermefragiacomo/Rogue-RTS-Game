class_name TileSetGeneration extends Node2D

var noise_height_text : NoiseTexture2D
var noise : Noise

var widht : int = 100
var height : int = 100

var source_id = 3
var block_atlas = Vector2i(0,0)
var ramp_atlas_north_east = Vector2i(0,1)
var ramp_atlas_north_west = Vector2i(1,1)
var ramp_atlas_south_east = Vector2i(0,3)
var ramp_atlas_south_west = Vector2i(1,3)
var middle_atlas_south = Vector2i(1, 7)
var middle_atlas_north = Vector2i(1, 8)
var middle_atlas_west = Vector2i(1, 9)
var middle_atlas_east = Vector2i(1, 10)
var triangle_atlas_south = Vector2i(0, 7)
var triangle_atlas_north = Vector2i(0, 8)
var triangle_atlas_west = Vector2i(0, 9)
var triangle_atlas_east = Vector2i(0, 10)

var ground: Ground

func _init(ground: Ground) -> void:
	self.ground = ground
	
	noise_height_text = NoiseTexture2D.new()
	noise_height_text.noise = FastNoiseLite.new()
	noise = noise_height_text.noise
	
	generate_world()

func find_tile_map_layer_index(global_mouse_position: Vector2i) -> int:
	var index = ground.tile_map_layers.size()-1
	var found = false
	while (not found) && (index >= 0):
		var layer = ground.tile_map_layers[index]
		var local_mouse_pos = layer.to_local(global_mouse_position)
		var cell_coords = layer.local_to_map(local_mouse_pos)
		
		if (ground.tile_map_layers[index].get_cell_atlas_coords(cell_coords).x != -1):
			found = true
		else:
			index -= 1
	return index

func generate_world():
	var old_coord;
	var old_tile_map_layer_index
	
	for x in range(widht):
		for y in range(height):
			var noise_val = noise.get_noise_2d(x, y);
			var tile_map_layer_index = round(((noise_val + 0.68607872724533) * 10)/(0.5145708322525 + 0.68607872724533))
			#tile_map_layers[tile_map_layer_index].set_cell(Vector2i(x,y) - Vector2i(tile_map_layer_index, tile_map_layer_index), source_id, block_atlas)
			
			if x == 0:
				if y == 0:
					old_tile_map_layer_index = tile_map_layer_index
					old_coord = Vector2i(x,y) - Vector2i(tile_map_layer_index, tile_map_layer_index);
			
			var layer = ground.tile_map_layers[tile_map_layer_index]
			var layer_below = ground.tile_map_layers[tile_map_layer_index-1]
			var old_layer = ground.tile_map_layers[old_tile_map_layer_index]
			var old_layer_above = ground.tile_map_layers[old_tile_map_layer_index+1]
			
			var same_old_coord = Vector2i(x,y) - Vector2i(old_tile_map_layer_index, old_tile_map_layer_index)
			var above_old_coord = Vector2i(x,y) - Vector2i(old_tile_map_layer_index+1, old_tile_map_layer_index+1)
			var same_coord = Vector2i(x,y) - Vector2i(tile_map_layer_index, tile_map_layer_index)
			var same_coord_below = Vector2i(x,y) - Vector2i(tile_map_layer_index-1, tile_map_layer_index-1)
			var last_x_layer_coord = Vector2i(x - 1,y) - Vector2i(tile_map_layer_index, tile_map_layer_index)
			var last_x_layer_coord_above = Vector2i(x - 1,y) - Vector2i(old_tile_map_layer_index+1, old_tile_map_layer_index+1)
			var last_x_layer_old_coord_below = Vector2i(x - 1,y) - Vector2i(old_tile_map_layer_index-1, old_tile_map_layer_index-1)
			var last_x_layer_coord_below = Vector2i(x - 1,y) - Vector2i(tile_map_layer_index-1, tile_map_layer_index-1)
			var last_x_layer_old_coord = Vector2i(x - 1,y) - Vector2i(old_tile_map_layer_index, old_tile_map_layer_index)
			
			if old_tile_map_layer_index < tile_map_layer_index: # higher layer
				if layer.get_cell_atlas_coords(last_x_layer_coord) == block_atlas:
					layer.set_cell(same_coord, source_id, middle_atlas_east)
				else:
					if (layer_below.get_cell_atlas_coords(last_x_layer_coord_below) == block_atlas):
						if (layer.get_cell_atlas_coords(last_x_layer_coord) != triangle_atlas_north):
							layer.set_cell(same_coord, source_id, triangle_atlas_north)
							layer_below.set_cell(same_coord_below, source_id, block_atlas)
						else:
							layer.set_cell(same_coord, source_id, ramp_atlas_south_west)
					else:
						if (layer.get_cell_atlas_coords(last_x_layer_coord) == middle_atlas_north || layer.get_cell_atlas_coords(last_x_layer_coord) == ramp_atlas_south_east || layer.get_cell_atlas_coords(last_x_layer_coord) == middle_atlas_west):
							layer.set_cell(same_coord, source_id, middle_atlas_east)
						else:
							if (layer.get_cell_atlas_coords(last_x_layer_coord) == ramp_atlas_north_west):
								layer.set_cell(same_coord, source_id, triangle_atlas_north)
								layer_below.set_cell(same_coord_below, source_id, block_atlas)
							else:
								if (layer.get_cell_atlas_coords(same_coord - Vector2i(0, 1)) == ramp_atlas_north_west):
									layer.set_cell(same_coord, source_id, middle_atlas_east)
								else:
									layer.set_cell(same_coord, source_id, ramp_atlas_south_west)
			else: # lower layer
				if old_tile_map_layer_index > tile_map_layer_index:
					if old_layer.get_cell_atlas_coords(last_x_layer_old_coord) == block_atlas:
						old_layer.set_cell(same_old_coord, source_id, middle_atlas_south)
					else:
						if old_layer.get_cell_atlas_coords(last_x_layer_old_coord) == ramp_atlas_south_east || old_layer.get_cell_atlas_coords(last_x_layer_old_coord) == middle_atlas_west || old_layer.get_cell_atlas_coords(last_x_layer_old_coord) == triangle_atlas_north || old_layer.get_cell_atlas_coords(last_x_layer_old_coord) == middle_atlas_north:
							old_layer.set_cell(same_old_coord, source_id, middle_atlas_south)
						else:
							if (old_layer.get_cell_atlas_coords(old_coord) == middle_atlas_west || old_layer.get_cell_atlas_coords(old_coord) == triangle_atlas_north):
								old_layer.set_cell(same_old_coord, source_id, triangle_atlas_west)
								layer.set_cell(same_coord, source_id, block_atlas)
							else:
								if (old_layer.get_cell_atlas_coords(old_coord) == ramp_atlas_south_east):
									old_layer.set_cell(same_old_coord, source_id, triangle_atlas_west)
									layer.set_cell(same_coord, source_id, block_atlas)
								else:
									old_layer.set_cell(same_old_coord, source_id, ramp_atlas_north_east)
				else: # same layer
					if (layer.get_cell_atlas_coords(last_x_layer_coord) == ramp_atlas_south_west) || (layer.get_cell_atlas_coords(last_x_layer_coord) == middle_atlas_east):
						layer.set_cell(same_coord, source_id, middle_atlas_north)
					else:
						match (old_layer_above.get_cell_atlas_coords(last_x_layer_coord_above)):
							block_atlas, middle_atlas_west, ramp_atlas_south_east, middle_atlas_north:
								old_layer_above.set_cell(above_old_coord, source_id, ramp_atlas_north_west)
							ramp_atlas_north_east:
								old_layer.set_cell(same_old_coord, source_id, block_atlas)
								old_layer_above.set_cell(above_old_coord, source_id, triangle_atlas_south)
							middle_atlas_south:
								old_layer.set_cell(same_old_coord, source_id, block_atlas)
								old_layer_above.set_cell(above_old_coord, source_id, triangle_atlas_south)
							ramp_atlas_south_west:
								old_layer.set_cell(same_old_coord, source_id, block_atlas)
								old_layer_above.set_cell(above_old_coord, source_id, triangle_atlas_east)
							middle_atlas_east:
								old_layer.set_cell(same_old_coord, source_id, block_atlas)
								old_layer_above.set_cell(above_old_coord, source_id, triangle_atlas_east)
							triangle_atlas_west:
								old_layer.set_cell(same_old_coord, source_id, block_atlas)
								old_layer_above.set_cell(above_old_coord, source_id, triangle_atlas_south)
							triangle_atlas_north:
								old_layer.set_cell(same_old_coord, source_id, block_atlas)
								old_layer_above.set_cell(above_old_coord, source_id, triangle_atlas_east)
							_:
								match (layer_below.get_cell_atlas_coords(last_x_layer_old_coord_below)):
									block_atlas:
										match(layer.get_cell_atlas_coords(last_x_layer_coord)):
											triangle_atlas_north:
												layer.set_cell(same_coord, source_id, middle_atlas_north)
											triangle_atlas_west:
												layer.set_cell(same_coord, source_id, middle_atlas_west)
											ramp_atlas_north_east:
												layer.set_cell(same_coord, source_id, middle_atlas_west)
											_:
												layer.set_cell(same_coord, source_id, ramp_atlas_south_east)
									_:
										if layer.get_cell_atlas_coords(last_x_layer_coord) == ramp_atlas_north_east:
											layer.set_cell(same_coord, source_id, middle_atlas_west)
										else:
											if layer.get_cell_atlas_coords(last_x_layer_coord) == middle_atlas_south:
												layer.set_cell(same_coord, source_id, middle_atlas_west)
											else:
												if layer.get_cell_atlas_coords(last_x_layer_coord) == ramp_atlas_north_west:
													layer.set_cell(same_coord, source_id, ramp_atlas_south_east)
												else:
													layer.set_cell(same_coord, source_id, block_atlas)
			
			old_tile_map_layer_index = tile_map_layer_index
			old_coord = same_coord;
