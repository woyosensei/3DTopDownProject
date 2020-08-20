extends Control

onready var animPlayer = $AnimationPlayer
var changeToScene


func start(anim, newScene):
	animPlayer.play(anim)
	changeToScene = newScene


func deleteScene():
	queue_free()


func changeScene():
	get_tree().change_scene(changeToScene)
