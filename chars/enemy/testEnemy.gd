extends KinematicBody


var path = []
var pathInd = 0
var speed = 5
onready var nav = get_parent()

func _ready() -> void:
	add_to_group("units")


func _physics_process(delta: float) -> void:
	if pathInd < path.size():
		var moveVec = (path[pathInd] - global_transform.origin + Vector3(0, 1, 0))
		if moveVec.length() < 0.1:
			pathInd += 1
		else:
			move_and_slide(moveVec.normalized() * speed, Vector3.UP)


func moveTo(targetPos):
	path = nav.get_simple_path(global_transform.origin, targetPos)
	pathInd = 0
