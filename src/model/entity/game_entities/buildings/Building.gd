class_name Building extends Entity

var source_id: int
var x_horizontal: int
var y_horizontal: int
var height: int

var x_tile: int
var y_tile: int

var tile_map_layer_index: int

func _init(max_health: int, health: int, entity_name: String, id: int, team: int, source_id: int, x_horizontal: int, y_horizontal: int, height: int):
	super(max_health, health, entity_name, id, team)
	self.source_id = source_id
	self.x_horizontal = x_horizontal
	self.y_horizontal = y_horizontal
	self.height = height
	set_tile_map_layer_index(z_index)

func set_x_tile(x_tile: int):
	self.x_tile = x_tile

func set_y_tile(y_tile: int):
	self.y_tile = y_tile
	
func set_tile_map_layer_index(tile_map_layer_index: int) -> void:
	self.tile_map_layer_index = tile_map_layer_index
	z_index = tile_map_layer_index

func set_tile_position(tile_map_layer_index: int, x_tile: int, y_tile: int):
	set_tile_map_layer_index(tile_map_layer_index)
	set_x_tile(x_tile)
	set_y_tile(y_tile)

func _to_string() -> String:
	return super() + " " + entity_name + ": tile_map_layer_index=" + str(tile_map_layer_index) + "; x_tile=" + str(x_tile) + "; y_tile=" + str(y_tile)
