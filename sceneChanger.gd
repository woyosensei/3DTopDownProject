extends Spatial

export var newScenePath : String
export var worldTeleport : bool

onready var worldSpawn = $Position3D


func _ready() -> void:
	if worldTeleport:
		generalInGame.isWorldSpawn = true
	else:
		generalInGame.isWorldSpawn = false


func _on_Area_body_entered(body: Node) -> void:
	SpawnPoints.worldSpawnPoint = worldSpawn
	SpawnPoints.spawnPosition = worldSpawn.transform.origin
	SpawnPoints.spawnRotation = worldSpawn.transform.basis
	body.coverScene(newScenePath)
