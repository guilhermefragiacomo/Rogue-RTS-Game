class_name BuildingManager extends Node

var placement: BuildingPlacement
var selection: BuildingSelection
var preview: BuildingPreview
var factory: BuildingFactory

var house_outline: Sprite2D

func _init(preview_building: Sprite2D, house_outline: Sprite2D) -> void:
	placement = BuildingPlacement.new()
	selection = BuildingSelection.new()
	preview = BuildingPreview.new(preview_building)
	factory = BuildingFactory.new()
	
	self.house_outline = house_outline

func place_building(data: Data, mouse_pos: Vector2i, id: String):
	var building: Building = factory.create_building(id)
	var new_building = placement.place_building(data.ground, building, mouse_pos)
	
	if (new_building != null):
		data.buildings.append(new_building)

func check_if_can_build(data: Data, mouse_pos: Vector2i, id: String):
	var building: Building = factory.create_building(id)
	placement.check_if_can_build(data.ground, building, mouse_pos)

func select_building(data: Data, mouse_pos: Vector2i):
	var selected_building = selection.select_building(data.ground, data.buildings, mouse_pos)
	if (selected_building != null):
		house_outline.position = data.ground.get_position_by_tile_coord(data.zoom, selected_building.tile_map_layer_index, Vector2i(selected_building.x_tile, selected_building.y_tile))
		house_outline.visible = true

func set_preview_on(data: Data, mouse_pos: Vector2i, id: String):
	var building: Building = factory.create_building(id)
	preview.set_preview_visible()
	preview.set_preview_in_grid(data.ground, building, placement.check_if_can_build(data.ground, building, mouse_pos), mouse_pos)

func set_preview_off():
	preview.set_preview_not_visible()
