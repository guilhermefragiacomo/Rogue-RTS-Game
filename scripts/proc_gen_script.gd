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
var middle_atlas_east = Vector2i(1, 10)
var triangle_atlas_south = Vector2i(0, 7)
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
					
			if old_tile_map_layer_index < tile_map_layer_index: # higher layer
				if tile_map_layers[tile_map_layer_index].get_cell_atlas_coords(Vector2i(x - 1,y) - Vector2i(tile_map_layer_index, tile_map_layer_index)) == block_atlas:
					tile_map_layers[tile_map_layer_index].set_cell(Vector2i(x,y) - Vector2i(tile_map_layer_index, tile_map_layer_index), source_id, middle_atlas_east)
				else:
					tile_map_layers[tile_map_layer_index].set_cell(Vector2i(x,y) - Vector2i(tile_map_layer_index, tile_map_layer_index), source_id, ramp_atlas_south_west)
			else: # lower layer
				if old_tile_map_layer_index > tile_map_layer_index:
					if tile_map_layers[old_tile_map_layer_index].get_cell_atlas_coords(Vector2i(x - 1,y) - Vector2i(old_tile_map_layer_index, old_tile_map_layer_index)) == block_atlas:
						tile_map_layers[old_tile_map_layer_index].set_cell(Vector2i(x,y) - Vector2i(old_tile_map_layer_index, old_tile_map_layer_index), source_id, middle_atlas_south)
					else:
						tile_map_layers[old_tile_map_layer_index].set_cell(Vector2i(x,y) - Vector2i(old_tile_map_layer_index, old_tile_map_layer_index), source_id, ramp_atlas_north_east)
				else: # same layer
					if tile_map_layers[old_tile_map_layer_index+1].get_cell_atlas_coords(Vector2i(x - 1,y) - Vector2i(old_tile_map_layer_index+1, old_tile_map_layer_index+1)) == block_atlas:
						tile_map_layers[old_tile_map_layer_index+1].set_cell(Vector2i(x,y) - Vector2i(old_tile_map_layer_index+1, old_tile_map_layer_index+1), source_id, ramp_atlas_north_west)
					else:
						if tile_map_layers[old_tile_map_layer_index+1].get_cell_atlas_coords(Vector2i(x - 1,y) - Vector2i(old_tile_map_layer_index+1, old_tile_map_layer_index+1)) == ramp_atlas_north_east:
							tile_map_layers[old_tile_map_layer_index].set_cell(Vector2i(x,y) - Vector2i(old_tile_map_layer_index, old_tile_map_layer_index), source_id, block_atlas)
							tile_map_layers[old_tile_map_layer_index+1].set_cell(Vector2i(x,y) - Vector2i(old_tile_map_layer_index+1, old_tile_map_layer_index+1), source_id, triangle_atlas_south)
						else:
							if tile_map_layers[old_tile_map_layer_index+1].get_cell_atlas_coords(Vector2i(x - 1,y) - Vector2i(old_tile_map_layer_index+1, old_tile_map_layer_index+1)) == middle_atlas_south:
								tile_map_layers[old_tile_map_layer_index].set_cell(Vector2i(x,y) - Vector2i(old_tile_map_layer_index, old_tile_map_layer_index), source_id, block_atlas)
								tile_map_layers[old_tile_map_layer_index+1].set_cell(Vector2i(x,y) - Vector2i(old_tile_map_layer_index+1, old_tile_map_layer_index+1), source_id, triangle_atlas_south)
							else:
								tile_map_layers[tile_map_layer_index].set_cell(Vector2i(x,y) - Vector2i(tile_map_layer_index, tile_map_layer_index), source_id, block_atlas)
			
			old_tile_map_layer_index = tile_map_layer_index
			old_coord = Vector2i(x,y) - Vector2i(tile_map_layer_index, tile_map_layer_index);
