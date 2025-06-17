class_name BuildingPreview extends Node

var preview_building: Sprite2D
var preview_material: ShaderMaterial

func _init(preview_building: Sprite2D) -> void:
	self.preview_building = preview_building
	print(preview_building)
	preview_material = preview_building.material as ShaderMaterial

func set_preview_valid(is_valid: bool):
	if is_valid:
		preview_material.set_shader_parameter("tint_color", Color(0, 1, 0, 0.5))
	else:
		preview_material.set_shader_parameter("tint_color", Color(1, 0, 0, 0.5)) 

func set_preview_in_grid(ground: Ground, building: Building, can_build: bool, global_mouse_pos: Vector2i):
	
	var tile_pos = ground.get_tile_coords_ground(global_mouse_pos)

	set_preview_valid(can_build)
	
	var tile_map_layer = ground.tile_map_layers[ground.find_tile_map_layer_index_ground(global_mouse_pos)]
	
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(tile_pos)
	
	var world_pos = tile_map_layer.map_to_local(tile_pos)
	var final_pos = tile_map_layer.to_global(world_pos)
	preview_building.global_position = final_pos

func set_preview_visible():
	preview_building.visible = true
func set_preview_not_visible():
	preview_building.visible = false
