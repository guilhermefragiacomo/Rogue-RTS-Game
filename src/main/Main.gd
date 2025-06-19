class_name Main extends Node2D

@onready var light: PointLight2D = $PointLight2D
@onready var tile_map_container: Node2D = $YContainer

@onready var house_outline = $SprHouseOutline

@onready var preview_building = $SprHouse

var database: Data
var input_manager: InputManager
var building_manager: BuildingManager
var entity_manager: EntityManager

func _ready():
	database = Data.new(tile_map_container)
	building_manager = BuildingManager.new(preview_building, house_outline)
	entity_manager = EntityManager.new(tile_map_container)
	input_manager = InputManager.new(database, building_manager, entity_manager)
	
	resize_zoom(0)
	
func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		resize_zoom(1)
	if event.is_action_pressed("zoom_out"):
		resize_zoom(-1)

func resize_zoom(value: int):
	if (database.zoom + value >= 1):
		if (database.zoom + value <= 4):
			database.zoom += value
	self.scale = Vector2i(database.zoom, database.zoom)

func _process(delta: float):
	input_manager.process(delta, get_global_mouse_position())
