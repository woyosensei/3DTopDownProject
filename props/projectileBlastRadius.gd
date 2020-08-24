extends KinematicBody


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_Timer_timeout() -> void:
	queue_free()
