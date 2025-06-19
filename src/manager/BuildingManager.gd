class_name BuildingManager extends Node

var placement: BuildingPlacement
var selection: BuildingSelection
var preview: BuildingPreview
var factory: BuildingFactory
var database: BuildingDatabase

var house_outline: Sprite2D

func _init(preview_building: Sprite2D, house_outline: Sprite2D) -> void:
	placement = BuildingPlacement.new()
	selection = BuildingSelection.new()
	preview = BuildingPreview.new(preview_building)
	factory = BuildingFactory.new()
	database = BuildingDatabase.new()
	
	self.house_outline = house_outline

func place_building(data: Data, mouse_pos: Vector2i, id: String):
	var building: Building = factory.create_building(id)
	var new_building = placement.place_building(data.ground, building, mouse_pos)
	building.queue_free()
	
	if (new_building != null):
		database.add_building(new_building)

func check_if_can_build(data: Data, mouse_pos: Vector2i, id: String):
	var building: Building = factory.create_building(id)
	placement.check_if_can_build(data.ground, building, mouse_pos)
	building.queue_free()

func select_building(data: Data, mouse_pos: Vector2i):
	data.selected_building = selection.select_building(data.ground, database.buildings, mouse_pos)
	if (data.selected_building != null):
		house_outline.position = data.ground.get_position_by_tile_coord(data.zoom, data.selected_building.tile_map_layer_index, Vector2i(data.selected_building.x_tile, data.selected_building.y_tile))
		house_outline.visible = true
	else:
		house_outline.visible = false
func deselect(data: Data) -> void:
	data.selected_building = null
	house_outline.visible = false

func set_preview_on(data: Data, mouse_pos: Vector2i, id: String):
	var building: Building = factory.create_building(id)
	preview.set_preview_visible()
	preview.set_preview_in_grid(data.ground, building, placement.check_if_can_build(data.ground, building, mouse_pos), mouse_pos)
	building.queue_free()
func set_preview_off():
	preview.set_preview_not_visible()
