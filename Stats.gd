extends Node

export var maxHealth = 1 setget set_max_health
var health = 1 setget set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_max_health(h):
	maxHealth = h
	self.health = min(health, maxHealth)
	emit_signal("max_health_changed", maxHealth)

func set_health(h):
	health = h
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func _ready():
	self.health = maxHealth
