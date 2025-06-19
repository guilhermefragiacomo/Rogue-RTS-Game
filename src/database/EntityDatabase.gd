class_name EntityDatabase extends Node

var entities: Array[Entity]

func _init() -> void:
	entities = []

func add_entity(entity: Entity):
	entities.append(entity)
	print("adicionei esse tanga " + str(entity))

func remove_entity(entity: Entity):
	entities.erase(entity)
	entity.queue_free()
