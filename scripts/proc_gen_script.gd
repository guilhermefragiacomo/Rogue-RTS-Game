extends Node2D

@export var noise_height_text : NoiseTexture2D
var noise : Noise

@export var zoom: int = 4

var widht : int = 100
var height : int = 100

@onready var light: PointLight2D = $PointLight2D

@onready var container: Node2D = $Container
var source_id = 5
var block_atlas = Vector2i(0,0)
var ramp_atlas_north_east = Vector2i(0,1)
var ramp_atlas_north_west = Vector2i(1,1)
var ramp_atlas_south_east = Vector2i(0,3)
var ramp_atlas_south_west = Vector2i(1,3)
var middle_atlas_south = Vector2i(1, 7)
var middle_atlas_north = Vector2i(1, 8)
var middle_atlas_west = Vector2i(0, 9)
var middle_atlas_east = Vector2i(1, 10)
var triangle_atlas_south = Vector2i(0, 7)
var triangle_atlas_north = Vector2i(0, 8)
var triangle_atlas_west = Vector2i(0, 9)
var triangle_atlas_east = Vector2i(0, 10)

func get_all_tile_map_layers():
	var tile_map_layers = []
	for child in container.get_children():
		if (child is TileMapLayer):
			tile_map_layers.append(child)
	return tile_map_layers

var tile_map_layers = []

func _ready():
	noise = noise_height_text.noise
	tile_map_layers = get_all_tile_map_layers()
	resize_zoom(0)
	generate_world()

func resize_zoom(value: int):
	if (zoom + value >= 1):
		if (zoom + value <= 4):
			zoom += value
	self.scale = Vector2i(zoom, zoom)

func _process(delta: float):
	if Input.is_action_just_released("zoom_in"):
		resize_zoom(1)
	if Input.is_action_just_released("zoom_out"):
		resize_zoom(-1)
	light.position = get_local_mouse_position()
	
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
			
			var layer = tile_map_layers[tile_map_layer_index]
			var layer_below = tile_map_layers[tile_map_layer_index-1]
			var old_layer = tile_map_layers[old_tile_map_layer_index]
			var old_layer_above = tile_map_layers[old_tile_map_layer_index+1]
			
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
						layer.set_cell(same_coord, source_id, ramp_atlas_south_west)
			else: # lower layer
				if old_tile_map_layer_index > tile_map_layer_index:
					if old_layer.get_cell_atlas_coords(last_x_layer_old_coord) == block_atlas:
						old_layer.set_cell(same_old_coord, source_id, middle_atlas_south)
					else:
						if old_layer.get_cell_atlas_coords(last_x_layer_old_coord) == triangle_atlas_west:
							old_layer.set_cell(same_old_coord, source_id, ramp_atlas_north_east)
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
							block_atlas:
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
							_:
								match (layer_below.get_cell_atlas_coords(last_x_layer_old_coord_below)):
									block_atlas:
										if (layer.get_cell_atlas_coords(last_x_layer_coord) == triangle_atlas_north):
											layer.set_cell(same_coord, source_id, middle_atlas_north)
										else: 
											layer.set_cell(same_coord, source_id, ramp_atlas_south_east)
									_:
										layer.set_cell(same_coord, source_id, block_atlas)
			
			old_tile_map_layer_index = tile_map_layer_index
			old_coord = same_coord;
