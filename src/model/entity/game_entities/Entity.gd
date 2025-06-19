class_name Entity extends Sprite2D

var max_health: int
var health: int
var entity_name: String
var id: int
var team: int

func _init(max_health: int, health: int, entity_name: String, id: int, team: int) -> void:
	self.max_health = max_health
	self.health = health
	self.entity_name = entity_name
	self.id = id
	self.team = team

func _to_string() -> String:
	return "max_health:" + str(max_health) + " health:" + str(health) + " name:" + entity_name + " id:" + str(id) + " team:" + str(team)
