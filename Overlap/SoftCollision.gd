extends Area2D

var areas = Array()

func is_colliding():
	areas = get_overlapping_areas()
	return areas.size() > 0

func get_push_vector():
	var pushVector = Vector2.ZERO
	var area = areas[0]
	pushVector = area.global_position.direction_to(global_position)
	return pushVector
