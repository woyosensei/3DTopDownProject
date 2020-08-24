extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("whaaaaa'")
	var dBox = preload("res://dialogue/DialogueControl.tscn")
	dBox = dBox.instance()
	print(dBox)
	get_tree().get_current_scene().add_child(dBox)
	var dB = dBox.get_child(0)
	dB.start("startGameText.json", ["npcName"], generalInGame.player, true, false)
	print(dB)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if SpawnPoints.worldSpawnPoint == null:
		return
	else:
		generalInGame.player.global_transform.origin = SpawnPoints.spawnPosition
		generalInGame.player.global_transform.basis = SpawnPoints.spawnRotation
