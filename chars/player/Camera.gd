extends Camera


var rayLength = 1000

onready var timer = $Timer

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var from = project_ray_origin(event.position)
		var to = from + project_ray_normal(event.position) * rayLength
		var spaceState = get_world().direct_space_state
		var result = spaceState.intersect_ray(from, to, [], 1)
		if result:
			get_tree().call_group("units", "moveTo", result.position)




func _on_Timer_timeout() -> void:
	var from = project_ray_origin(get_viewport().get_mouse_position())
	var to = from + project_ray_normal(get_viewport().get_mouse_position()) * rayLength
	var spaceState = get_world().direct_space_state
	var result = spaceState.intersect_ray(from, to, [], 1)
	if result:
		get_tree().call_group("units", "moveTo", result.position)
