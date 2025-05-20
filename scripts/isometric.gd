extends Node2D

@export var zoom: int = 4
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var tile_map_layer2: TileMapLayer = $TileMapLayer2
@onready var tile_map_container: Node2D = $TileMapContainer
@onready var y_sort_node: Node2D = $YSort
@onready var preview_building = y_sort_node.get_node("SprHouse")
@export var building_scene: PackedScene
@onready var preview_material = y_sort_node.get_node("SprHouse").material as ShaderMaterial

func get_all_tile_map_layers(parent_node):
	var tile_map_layers = []
	for child in parent_node.get_children():
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
		
		var tile_map_layer = find_tile_map_layer(tile_pos)
		
		var world_pos = tile_map_layer.map_to_local(tile_pos)
		
		var atlas_coords = tile_map_layer.get_cell_atlas_coords(tile_pos)
		if (atlas_coords.x != -1):
			var offset = tile_offsets.get(atlas_coords.x, Vector2.ZERO)
			
			var final_pos = tile_map_layer.to_global(world_pos + offset)
			
			var new_building = building_scene.instantiate()
			y_sort_node.add_child(new_building)
			new_building.global_position = final_pos

func resize_zoom(value: int):
	if (zoom + value >= 1):
		if (zoom + value <= 4):
			zoom += value
	self.scale = Vector2i(zoom, zoom)

func _ready() -> void:
	tile_map_layers = get_all_tile_map_layers(get_node("TileMapContainer"))
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
	
	var tile_map_layer = find_tile_map_layer(tile_pos)
	
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(tile_pos)
	if (atlas_coords.x == -1):
		atlas_coords.x = 0
	var offset = tile_offsets.get(atlas_coords.x, Vector2.ZERO)
	
	var world_pos = tile_map_layer.map_to_local(tile_pos)
	var final_pos = tile_map_layer.to_global(world_pos + offset)
	preview_building.global_position = final_pos

func get_mouse_tile_coords() -> Vector2i:
	var mouse_pos = get_global_mouse_position()
	return tile_map_layers[0].local_to_map(tile_map_layers[0].to_local(mouse_pos))
	
func find_tile_map_layer(tile_pos: Vector2i) -> TileMapLayer:
	var found = false
	var index = tile_map_layers.size()-1
	var actual_tile_map_layer = tile_map_layers[0]
	while (not found) && (index > 0):
		if (tile_map_layers[index].get_cell_atlas_coords(tile_pos).x != -1):
			found = true
			actual_tile_map_layer = tile_map_layers[index]
		index -= 1
	return actual_tile_map_layer
