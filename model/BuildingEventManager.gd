class_name BuildingEventManager extends Node

var listeners: Dictionary

func add(eventType: String, listener: BuildingEventListener):
	listeners.set(eventType, listener)

func remove(eventType: String, listener: BuildingEventListener):
	listeners.set(eventType, listener)
