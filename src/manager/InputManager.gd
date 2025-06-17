class_name InputManager extends Node2D

enum InputMode {
	DEFAULT,
	PLACING_BUILDING,
	SELECTING
}

var current_mode: InputMode = InputMode.DEFAULT
var handlers = {}

var building_manager: BuildingManager
var data: Data

func _init(data: Data, buildingManager: BuildingManager) -> void:
	self.building_manager = buildingManager
	self.data = data
	
	handlers[InputMode.DEFAULT] = handle_default_input
	handlers[InputMode.PLACING_BUILDING] = handle_placing_input
	handlers[InputMode.SELECTING] = handle_selecting_input
	
	current_mode = InputMode.DEFAULT

func set_default_mode():
	current_mode = InputMode.DEFAULT
func set_placing_building_mode():
	current_mode = InputMode.PLACING_BUILDING
func set_select_building_mode():
	current_mode = InputMode.SELECTING

func process(delta, mouse_pos: Vector2i):
	if handlers.has(current_mode):
		handlers[current_mode].call(mouse_pos)

func handle_default_input(mouse_pos: Vector2i):
	if Input.is_action_just_pressed("left_click"):
		print("left-click")
	if Input.is_action_just_pressed("right_click"):
		print("right-click")
	if Input.is_action_just_pressed("select_house_1"):
		print("building")
		current_mode = InputMode.PLACING_BUILDING
	if Input.is_action_just_pressed("selecting"):
		print("selecting")
		current_mode = InputMode.SELECTING

func handle_placing_input(mouse_pos: Vector2i):
	building_manager.set_preview_on(data, mouse_pos, "simple_house")
	if Input.is_action_just_pressed("left_click"):
		building_manager.place_building(data, mouse_pos, "simple_house")
		print("left-click (tried to create)")
	if Input.is_action_just_pressed("right_click"):
		print("right-click (default mode)")
		building_manager.set_preview_off()
		current_mode = InputMode.DEFAULT

func handle_selecting_input(mouse_pos: Vector2i):
	if Input.is_action_just_pressed("left_click"):
		building_manager.select_building(data, mouse_pos)
		print("left-click (tried to select)")
	if Input.is_action_just_pressed("right_click"):
		print("right-click (default mode)")
		current_mode = InputMode.DEFAULT
