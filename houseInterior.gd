extends Node


onready var player = $player
onready var spawnPoint = $Position3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.global_transform.origin = spawnPoint.global_transform.origin
	player.global_transform.basis = spawnPoint.global_transform.basis
