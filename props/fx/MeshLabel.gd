extends Spatial

onready var model = $MeshInstance
onready var viewport = $Viewport
onready var label = $Viewport/RichTextLabel


func start(text, speed):
	pass


func _process(delta: float) -> void:
	var target = generalInGame.camera
	look_at(target.global_transform.origin, Vector3.UP)
