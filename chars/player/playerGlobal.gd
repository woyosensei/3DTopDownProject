extends Node


var maxPlayerHealth = 100
var playerHealth = maxPlayerHealth
var playerLvl = 1
var playerExp = 0
var playerPowerLevel = 1


func _ready() -> void:
	playerHealth = clamp(playerHealth, 0, maxPlayerHealth)


func _process(delta: float) -> void:
	playerHealth = clamp(playerHealth, 0, maxPlayerHealth)
