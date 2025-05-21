extends Node2D

@export var zoom: int = 4
@onready var container: Node2D = $Container
@onready var y_sort_node: Node2D = $Container
@onready var preview_building = $Container/SprHouse
@onready var preview_material = preview_building.material as ShaderMaterial

func get_all_tile_map_layers(parent_node):
	var tile_map_layers = []
	for child in parent_node.get_children():
		if (child is TileMapLayer):
			tile_map_layers.append(child)
	return tile_map_layers

var occupied_tiles = {}
var tile_map_layers = []

var tile_offsets = {
	0: Vector2(0, -8),
	1: Vector2(0, 0),
}

func place_building(tile_pos: Vector2i):
	
	var free_space = true
	if occupied_tiles.has(tile_pos):
		free_space = false
	if occupied_tiles.has(Vector2i(tile_pos.x - 1, tile_pos.y)):
		free_space = false
	if occupied_tiles.has(Vector2i(tile_pos.x, tile_pos.y - 1)):
		free_space = false
	if occupied_tiles.has(Vector2i(tile_pos.x - 1, tile_pos.y - 1)):
		free_space = false
		
	if free_space:
		occupied_tiles[tile_pos] = true
		occupied_tiles[Vector2i(tile_pos.x - 1, tile_pos.y)] = true
		occupied_tiles[Vector2i(tile_pos.x, tile_pos.y - 1)] = true
		occupied_tiles[Vector2i(tile_pos.x - 1, tile_pos.y - 1)] = true
		
		var tile_map_layer_index = find_tile_map_layer_index(tile_pos)
		var tile_map_layer = tile_map_layers[tile_map_layer_index]
		
		var tile_set = tile_map_layer.tile_set
		var tile_set_source = tile_set.get_source(1)
		
		var horizontal = 0
		for i in range(0, tile_set_source.get_tiles_count()-1):
			if (tile_set_source.has_tile(Vector2i(i, 0))):
				horizontal += 1
		var vertical = tile_set_source.get_tiles_count()/horizontal
		
		var atlas_coords = tile_map_layer.get_cell_atlas_coords(tile_pos)
		
		var x_index = tile_pos.x
		var y_index = tile_pos.y + 1
		print("Camada ", tile_map_layer_index + 2)
		for i in range(vertical-1, -1, -1):
			for j in range(0, horizontal):
				tile_map_layers[tile_map_layer_index + 1].set_cell(Vector2i(x_index, y_index), 1, Vector2i(j, i))
				x_index += 1
				y_index -= 1
			tile_map_layer_index += 1
			x_index -= 4

func resize_zoom(value: int):
	if (zoom + value >= 1):
		if (zoom + value <= 4):
			zoom += value
	self.scale = Vector2i(zoom, zoom)

func _ready() -> void:
	tile_map_layers = get_all_tile_map_layers(container)
	resize_zoom(0)

func _unhandled_input(event):
	if event.is_action_pressed("place_building"):
		var tile_pos = get_mouse_tile_coords()
		place_building(tile_pos)

func set_preview_valid(is_valid: bool):
	if is_valid:
		preview_material.set_shader_parameter("tint_color", Color(0, 1, 0, 0.5))
	else:
		preview_material.set_shader_parameter("tint_color", Color(1, 0, 0, 0.5)) 

func _process(delta: float):
	if Input.is_action_just_released("zoom_in"):
		resize_zoom(1)
	if Input.is_action_just_released("zoom_out"):
		resize_zoom(-1)
	
	var tile_pos = get_mouse_tile_coords()
	var free_space = true
	if occupied_tiles.has(tile_pos):
		free_space = false
	if occupied_tiles.has(Vector2i(tile_pos.x - 1, tile_pos.y)):
		free_space = false
	if occupied_tiles.has(Vector2i(tile_pos.x, tile_pos.y - 1)):
		free_space = false
	if occupied_tiles.has(Vector2i(tile_pos.x - 1, tile_pos.y - 1)):
		free_space = false
	
	set_preview_valid(free_space)
	
	var tile_map_layer = tile_map_layers[find_tile_map_layer_index(tile_pos)]
	
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(tile_pos)
	if (atlas_coords.x == -1):
		atlas_coords.x = 0
		set_preview_valid(false)
	var offset = tile_offsets.get(atlas_coords.x, Vector2.ZERO)
	
	var world_pos = tile_map_layer.map_to_local(tile_pos)
	var final_pos = tile_map_layer.to_global(world_pos + offset)
	preview_building.global_position = final_pos

func get_mouse_tile_coords() -> Vector2i:
	var mouse_pos = get_global_mouse_position()
	return tile_map_layers[0].local_to_map(tile_map_layers[0].to_local(mouse_pos))
	
func find_tile_map_layer_index(tile_pos: Vector2i) -> int:
	var index = tile_map_layers.size()-1
	var found = false
	while (not found) && (index >= 0):
		if (tile_map_layers[index].get_cell_atlas_coords(tile_pos).x != -1):
			found = true
		else:
			index -= 1
	return index
