extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SpawnPoints.worldSpawnPoint == null:
		return
	else:
		generalInGame.player.global_transform.origin = SpawnPoints.spawnPosition
		generalInGame.player.global_transform.basis = SpawnPoints.spawnRotation
