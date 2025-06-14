extends Node2D

@export var zoom: int = 4

@onready var light: PointLight2D = $PointLight2D
@onready var preview_building = $Container/SprHouse
@onready var preview_material = preview_building.material as ShaderMaterial
@onready var container: Node2D = $Container

var ground: Ground
var building: Building = SimpleHouse.new()
var buildings = []

func _ready():
	ground = Ground.new(container, [3, 5])
	ground.get_all_tile_map_layers()
	var procedural_ground = await TileSetGeneration.new(ground)
	
	resize_zoom(0)
	
func _unhandled_input(event):
	if event.is_action_pressed("place_building"):
		var tile_pos = ground.get_mouse_tile_coords(ground.find_tile_map_layer_index_ground(get_global_mouse_position()), get_global_mouse_position())
		
		buildings.append(building.place_building(ground, tile_pos, get_global_mouse_position()))

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
	light.position = get_local_mouse_position() + Vector2(90, 0)
	
	set_preview_in_grid()

func set_preview_valid(is_valid: bool):
	if is_valid:
		preview_material.set_shader_parameter("tint_color", Color(0, 1, 0, 0.5))
	else:
		preview_material.set_shader_parameter("tint_color", Color(1, 0, 0, 0.5)) 

func set_preview_in_grid():
	var tile_pos = ground.get_mouse_tile_coords(ground.find_tile_map_layer_index_ground(get_global_mouse_position()), get_global_mouse_position())

	set_preview_valid(building.check_if_can_build(ground, tile_pos, get_global_mouse_position()))
	
	var tile_map_layer = ground.tile_map_layers[ground.find_tile_map_layer_index_ground(get_global_mouse_position())]
	
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(tile_pos)
	
	var world_pos = tile_map_layer.map_to_local(tile_pos)
	var final_pos = tile_map_layer.to_global(world_pos)
	preview_building.global_position = final_pos
