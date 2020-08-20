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




func _on_Area_body_entered(body: Node) -> void:
	lookingAtPlayer = true
	player = body
	print(player)
	print(npcName)


func _on_Area_body_exited(body: Node) -> void:
	lookingAtPlayer = false
	player = null
