extends Spatial


func _process(delta: float) -> void:
	$Particles.rotate_y(deg2rad(1))
