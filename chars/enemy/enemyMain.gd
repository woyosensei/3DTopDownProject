extends KinematicBody


export var speed = 100
export var health = 100
export var armor = 0
export var ki = 0
export var baseDamage = 10
export var detectionRange = 20

var target
var lastTargetPosition : Vector3 = Vector3()
var velocity = Vector3.ZERO

onready var timer = $Timer
onready var followTimer = $followTimer
onready var playerDetector = $playerDetector
onready var cooldown = $attackCooldown
onready var animPlayer = $AnimationPlayer
onready var lastPositionTimer = $lastPositionTimer

var playerSet = false
var playerDetected = false
var playerVisible = false
var lookingForPlayer = false
var canAttack = true
var isInAttackRange = false

enum {
	IDLE,
	WALK,
	SEARCH,
	ATTACK,
	FALL,
	DEAD
}

var state = IDLE

var animAttack
var animWalk
var animIdle


func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	target = get_tree().get_current_scene().get_node("player")
	set_process(true)
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if playerDetector.rotation_degrees.y < 100 and playerDetector.rotation_degrees.y > - 100:
		playerDetector.cast_to = Vector3(0, 0, -detectionRange /2)
	else:
		playerDetector.cast_to = Vector3(0, 0, -detectionRange)


func _process(delta: float) -> void:
	watchPlayer()
	print(lastPositionTimer.time_left)
#	print("player Detected: ", playerDetected, " looking for player: ", lookingForPlayer)
	if playerDetector.is_colliding() and playerDetector.get_collider() is KinematicBody:
		if lastPositionTimer.is_stopped():
			lastPositionTimer.start(1)
	elif playerDetector.is_colliding() and playerDetector.get_collider() != KinematicBody:
		lastPositionTimer.stop()
	else:
		pass


func watchPlayer():
	playerDetector.look_at(target.global_transform.origin + Vector3(0, 0.5, 0), Vector3.UP)
	

func _on_lastPositionTimer_timeout() -> void:
	lastTargetPosition = target.global_transform.origin
	print(lastTargetPosition)
