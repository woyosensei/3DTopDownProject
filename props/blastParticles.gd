extends Particles


func start(dir):
	emitting = true
	one_shot = true
	transform = dir


func _on_Timer_timeout() -> void:
	queue_free()
