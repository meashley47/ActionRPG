extends Control

var hearts = 4 setget set_hearts
var maxHearts = 4 setget set_max_hearts

onready var heartUIFull= $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty

func set_hearts(h):
	#Ensures that our hearts is never less than 0 or greater than max
	hearts = clamp(h, 0, maxHearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * 15

func set_max_hearts(h):
	#Ensures our maxHearts is never less than 1
	maxHearts = max(h, 1)
	self.hearts = min(hearts, maxHearts)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = maxHearts * 15

func _ready():
	self.maxHearts = PlayerStats.maxHealth
	self.hearts = PlayerStats.health
	#This will send the value from health_changed into set_hearts
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
