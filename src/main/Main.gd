class_name Main extends Node2D

@onready var light: PointLight2D = $PointLight2D
@onready var container: Node2D = $Container

@onready var house_outline = $SprHouseOutline

@onready var preview_building = $SprHouse

var database: Data
var input_manager: InputManager
var building_manager: BuildingManager

func _ready():
	database = Data.new(container)
	building_manager = BuildingManager.new(preview_building, house_outline)
	input_manager = InputManager.new(database, building_manager)
	
	resize_zoom(0)
	
func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		resize_zoom(1)
	if event.is_action_pressed("zoom_out"):
		resize_zoom(-1)
	"""
	if event.is_action_pressed("left_click"):
		selected_building = Building.select_building(ground, buildings, ground.get_tile_coords(get_global_mouse_position()), get_global_mouse_position())
		if (selected_building != null):
			house_outline.position = ground.get_position_by_tile_coord(zoom, selected_building.tile_map_layer_index, Vector2i(selected_building.x_tile, selected_building.y_tile))
			house_outline.visible = true
		else:
			house_outline.visible = false"""

func resize_zoom(value: int):
	if (database.zoom + value >= 1):
		if (database.zoom + value <= 4):
			database.zoom += value
	self.scale = Vector2i(database.zoom, database.zoom)

func _process(delta: float):
	input_manager.process(delta, get_global_mouse_position())
