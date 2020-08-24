extends KinematicBody


export var npcName : String = "NPCName"
export var npcHead : NodePath
export var turnHeadToPlayer : bool = false

var lookingAtPlayer = false
var player
var node_ref


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if lookingAtPlayer:
		if npcHead != "" and turnHeadToPlayer:
			var head = get_node(npcHead)
			head.look_at(player.global_transform.origin, Vector3(0, 1, 0))


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") and lookingAtPlayer:
		print(player)
		var dBox = preload("res://dialogue/DialogueControl.tscn")
		dBox = dBox.instance()
		get_tree().get_current_scene().add_child(dBox)
		var dB = dBox.get_child(0)
		dB.start("dialogue_1.json", [npcName], player, false, false)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _on_Area_body_entered(body: Node) -> void:
	lookingAtPlayer = true
	player = body


func _on_Area_body_exited(_body: Node) -> void:
	lookingAtPlayer = false
	player = null
