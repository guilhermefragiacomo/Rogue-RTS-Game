class_name EntityManager extends Node

var database: EntityDatabase

var ycontainer: Node2D

func _init(ycontainer: Node2D) -> void:
	database = EntityDatabase.new()
	
	self.ycontainer = ycontainer

func create_villager() -> void:
	var villager = Villager.new()
	villager.z_index = 20
	villager.position = Vector2i(10, 10)
	var texture: Texture2D = load("res://src/sprites/spr_villager.png")
	villager.texture = texture
	
	database.add_entity(villager)
	ycontainer.add_child(villager)
