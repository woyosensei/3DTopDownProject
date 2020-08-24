extends KinematicBody


var speed = 130
var target
var velocity = Vector3.ZERO

onready var timer = $Timer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_physics_process(false)
	if target == null:
		print("assigning player to target")
		target = generalInGame.player


func _physics_process(delta: float) -> void:
	aim()
	velocity = Vector3()
	velocity += -transform.basis.z * speed * delta
	velocity = move_and_slide(velocity, Vector3.UP)

# double check if player exist
func _on_Timer_timeout() -> void:
	if target == null:
		print("player NOT found")
		target = generalInGame.player
		timer.start()
	else:
		print("player found")
		timer.queue_free()
		set_physics_process(true)


func aim():
	var desiredRotation = transform.looking_at(target.transform.origin, Vector3.UP)
	var a = Quat(transform.basis.get_rotation_quat()).slerp(desiredRotation.basis.get_rotation_quat(), 0.02)
	set_transform(Transform(a, transform.origin))
