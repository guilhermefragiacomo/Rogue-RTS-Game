class_name SimpleHouse extends Building

func _init():
	super(1,2,1,6)

func set_position(tile_map_layer_index: int, x_tile: int, y_tile: int):
	set_tile_map_layer_index(tile_map_layer_index)
	set_x_tile(x_tile)
	set_y_tile(y_tile)
