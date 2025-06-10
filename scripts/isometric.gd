extends Node2D

@export var zoom: int = 4
@onready var container: Node2D = $Container
@onready var y_sort_node: Node2D = $Container
@onready var preview_building = $Container/SprHouse
@onready var preview_material = preview_building.material as ShaderMaterial

var buildings = {
	"simple_house": {
		"source_id" = 1,
		"x_horizontal" = 2,
		"y_horizontal" = 1,
		"height" = 6
	}
}

func get_all_tile_map_layers(parent_node):
	var tile_map_layers = []
	for child in parent_node.get_children():
		if (child is TileMapLayer):
			tile_map_layers.append(child)
	return tile_map_layers

var tile_map_layers = []

func check_if_can_build(tile_pos: Vector2i, building: Dictionary) -> bool:
	var tile_map_layer_index = find_tile_map_layer_index(get_global_mouse_position())
	var tile_map_layer = tile_map_layers[tile_map_layer_index]
		
	var x_horizontal = building.x_horizontal
	var y_horizontal = building.y_horizontal
	var vertical = building.height
	
	var x_index = tile_pos.x - 1
	var y_index = tile_pos.y
	
	var tile_map_layer_index_temp = tile_map_layer_index
	var free_space = true
	
	for y_atlas_check in range(vertical - 1, -1, -1):
		var y_atlas_check_temp = 0
		var x_index_temp = x_index + 1
		var y_index_temp = y_index + 1
		if (y_atlas_check == vertical - 1):
			for x_atlas_check in range(0, x_horizontal):
				if (tile_map_layers[tile_map_layer_index_temp].get_cell_atlas_coords(Vector2i(x_index_temp, y_index_temp)).y != 0):
					free_space = false
				y_atlas_check_temp = x_atlas_check
				for l in range(0, y_horizontal):
					y_index_temp -= 1
					y_atlas_check_temp += l + 1
					if (tile_map_layers[tile_map_layer_index_temp].get_cell_atlas_coords(Vector2i(x_index_temp, y_index_temp)).y != 0):
						free_space = false
				x_index_temp += 1
				y_index_temp += y_horizontal
		
		for x_atlas_check in range(0, x_horizontal):
			if (tile_map_layers[tile_map_layer_index_temp + 1].get_cell_atlas_coords(Vector2i(x_index, y_index)).x != -1):
				free_space = false
			y_atlas_check_temp = x_atlas_check
			for l in range(0, y_horizontal):
				y_index -= 1
				y_atlas_check_temp += l + 1
				if (tile_map_layers[tile_map_layer_index_temp + 1].get_cell_atlas_coords(Vector2i(x_index, y_index)).x != -1):
					free_space = false
			x_index += 1
			y_index += y_horizontal
		
		tile_map_layer_index_temp += 1
		x_index -= x_horizontal + 1
		y_index -= 1
	return free_space

func place_building(tile_pos: Vector2i, building: Dictionary):	
	if (check_if_can_build(tile_pos, building)):
		var tile_map_layer_index = find_tile_map_layer_index(get_global_mouse_position())
		var tile_map_layer = tile_map_layers[tile_map_layer_index]
		
		var atlas_coords = tile_map_layer.get_cell_atlas_coords(tile_pos)
		var tile_set_source = building.source_id
		
		var x_horizontal = building.x_horizontal
		var y_horizontal = building.y_horizontal
		var vertical = building.height
				
		var x_index = tile_pos.x - 1
		var y_index = tile_pos.y
		
		for y_atlas_place in range(vertical-1, -1, -1):
			var y_atlas_place_temp = 0
			for x_atlas_place in range(0, x_horizontal):
				tile_map_layers[tile_map_layer_index + 1].set_cell(Vector2i(x_index, y_index), tile_set_source, Vector2i(x_atlas_place, y_atlas_place))
				x_index += 1
				y_atlas_place_temp = x_atlas_place
				
				if x_atlas_place < x_horizontal - 1:
					for g in range(0, y_horizontal):
						y_index -= 1
						tile_map_layers[tile_map_layer_index + 1].set_cell(Vector2i(x_index -1, y_index), 2, Vector2i(3, 0))
					y_index += y_horizontal
			x_index -= 1
			for k in range(0, y_horizontal):
				y_index -= 1
				y_atlas_place_temp += k + 1
				tile_map_layers[tile_map_layer_index + 1].set_cell(Vector2i(x_index, y_index), tile_set_source, Vector2i(y_atlas_place_temp, y_atlas_place))
			tile_map_layer_index += 1
			x_index -= x_horizontal

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
		var tile_pos = get_mouse_tile_coords(find_tile_map_layer_index(get_global_mouse_position()))
		place_building(tile_pos, buildings.simple_house)

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
	
	var tile_pos = get_mouse_tile_coords(find_tile_map_layer_index(get_global_mouse_position()))

	set_preview_valid(check_if_can_build(tile_pos, buildings.simple_house))
	
	var tile_map_layer = tile_map_layers[find_tile_map_layer_index(get_global_mouse_position())]
	
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(tile_pos)
	
	var world_pos = tile_map_layer.map_to_local(tile_pos)
	var final_pos = tile_map_layer.to_global(world_pos)
	preview_building.global_position = final_pos


func get_mouse_tile_coords(tile_map_layer_index: int) -> Vector2i:
	var mouse_pos = get_global_mouse_position()
	return tile_map_layers[tile_map_layer_index].local_to_map(tile_map_layers[tile_map_layer_index].to_local(mouse_pos))
	

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
