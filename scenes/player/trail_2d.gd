extends Line2D

@export var length := 100

func _process(delta):
	global_position = Vector2.ZERO
	global_rotation = 0
	
	var point = get_parent().global_position
	
	add_point(point)
	if get_point_count() > length:
		remove_point(0)
