extends KinematicBody


export var speed = 100
export var friction = 0.9
export var gravity = 80
export var cameraRotSpeed = 250

var moveDir = Vector3()
var vel = Vector3()

var canMove = true
var isCastedLeft = true

onready var camera = $CameraRig/Camera
onready var cameraRig = $CameraRig
onready var cursor = $Cursor
onready var rect = $Control/ColorRect
onready var animPlayer = $AnimationPlayer
onready var spawnBullet = $spawnBullet
onready var auraGround = $auraParticles
onready var auraGroundParticles = $auraParticles/Particles
onready var ultraPivot = $ultraPivot
onready var ultraBlastCharge = $ultraPivot/ultraCharge
onready var ultraLight = $ultraPivot/chargeLight
onready var tween = $Tween
onready var ultraCooldown = $Timer
onready var spots = $ultraPivot/ultraCharge.get_children()

var changeScene
var startingBlastSize

var chargePower = 0
var blastRotX = 2
var spotBeamRadius = 1.8
var spotBeamHeight = 20

enum {
	MOVE,
	ATTACK,
	CHARGE_ULTRA_BEGIN,
	CHARGE_ULTRA_CHARGE,
	ULTRA_PREPARE_RELEASE,
	ULTRA_CAST,
	ULTRA_END,
	CHARGE_BEGIN,
	CHARGE,
	CHARGE_FIRE_BLAST,
	DEAD
}

var state = MOVE

enum {
	COMBO_NONE,
	COMBO_START,
	COMBO_1,
	COMBO_2,
	COMBO_3,
	COMBO_FINISH
}

var comboState = COMBO_NONE 


func _ready() -> void:
	cameraRig.set_as_toplevel(true)
	cursor.set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	auraGroundParticles.emitting = false
	
	ultraLight.light_energy = 0
	ultraLight.omni_range = 0
	
	for n in spots:
		if n is SpotLight:
			n.visible = false
			var m = n.get_child(0)
			m.mesh.bottom_radius = spotBeamRadius
			m.mesh.height = spotBeamHeight
	
	rect.visible = false
	
	startingBlastSize = ultraBlastCharge.mesh.radius
	
	if generalInGame.isShowingUp:
		canMove = false
		if generalInGame.isWorldSpawn == true:
			global_transform.origin = SpawnPoints.spawnPosition
			global_transform.basis = SpawnPoints.spawnRotation
		animPlayer.play("uncover")
	
	if generalInGame.player == null:
		generalInGame.player = self


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if state == MOVE:
		if Input.is_action_just_pressed("attack"):
			attack()
		if Input.is_action_just_pressed("heavyAttack"):
			heavyAttack()
		if Input.is_action_just_pressed("projectile"):
			specialAttack()
		if Input.is_action_pressed("special"):
			beginCharge()
			
	if state == CHARGE:
		if Input.is_action_pressed("special"):
			animPlayer.play("specialKeep")
		if Input.is_action_just_released("special"):
			animPlayer.play("specialRelease")
		if Input.is_action_pressed("special") && Input.is_action_just_pressed("projectile"):
			fireQuickBlast()
		if Input.is_action_pressed("ultra"):
			if ultraCooldown.is_stopped():
				ultraCharge()
	if state == CHARGE_FIRE_BLAST && Input.is_action_just_released("special"):
		state = MOVE
		endParticles()
	
	if state == CHARGE_BEGIN && Input.is_action_just_released("special"):
		state = MOVE
		endParticles()
	
	if state == CHARGE_ULTRA_BEGIN or state == CHARGE_ULTRA_CHARGE && chargePower < 5:
		if Input.is_action_just_released("special") or Input.is_action_just_released("ultra"):
			state = MOVE
			endParticles()
#			ultraBlastCharge.visible = false
			ultraBlastCharge.mesh.radius = startingBlastSize
			ultraBlastCharge.mesh.height = startingBlastSize * 2
			chargePower = 0
	if state == CHARGE_ULTRA_CHARGE && chargePower >= 5 && (Input.is_action_just_released("ultra")):
		castUltraRelease()
	
	
	if state == ULTRA_CAST && Input.is_action_just_pressed("ultra"):
		endParticles()
		ultraCooldown.start()
		yield(get_tree().create_timer(1), "timeout")
		state = MOVE


func _physics_process(delta: float) -> void:
	cameraFollowPlayer()
	rotateCamera(delta)
	
#	lookAtCursor()
#	rotatePlayerInDirection(delta)
	match state:
		MOVE:
			if not canMove:
				return
			else:
				run(delta)
		ULTRA_CAST:
			pass
		ULTRA_PREPARE_RELEASE:
			ultraBlastCharge.rotate_z(-deg2rad(blastRotX / (chargePower/100) * 5) * delta)
			ultraBlastCharge.rotate_x(deg2rad(0.2))
			for n in spots:
				if n is SpotLight:
					tween.interpolate_property(n, "spot_range", n.spot_range, 0, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
					tween.interpolate_property(n, "spot_angle", n.spot_angle, 0, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
					var m = n.get_child(0)
					m.mesh.bottom_radius -= (m.mesh.bottom_radius * delta * 1.5)
					m.mesh.height -= (m.mesh.bottom_radius * delta * 1.5)
		
	
	vel *= friction
	vel.y -= gravity * delta
	
	vel = move_and_slide(vel, Vector3.UP, true, 3)


func _process(delta: float) -> void:
	if state == CHARGE_ULTRA_CHARGE:
		if Input.is_action_pressed("ultra"):
			chargeBeam(delta)


#	look_at(global_transform.origin + vel, Vector3.UP)


func cameraFollowPlayer():
	var playerPos = global_transform.origin
	cameraRig.global_transform.origin = playerPos


func rotateCamera(delta):
	if Input.is_action_pressed("rotateCW"):
		cameraRig.rotate_y(deg2rad(-cameraRotSpeed * delta))
	if Input.is_action_pressed("rotateCCW"):
		cameraRig.rotate_y(deg2rad(cameraRotSpeed * delta))


func rotatePlayerInDirection(delta):
	look_at(global_transform.origin + vel, Vector3.UP)
#func lookAtCursor():
#	var playerPos = global_transform.origin
#	var dropPlane = Plane(Vector3(0, 1, 0), playerPos.y)
#
#	var rayLength = 1500
#	var mousePos = get_viewport().get_mouse_position()
#	var from = camera.project_ray_origin(mousePos)
#	var to = from + camera.project_ray_normal(mousePos) * rayLength
#	var cursorPos = dropPlane.intersects_ray(from, to)
#
#	cursor.global_transform.origin = cursorPos + Vector3(0, 0.5, 0)
#
#	look_at(cursorPos, Vector3.UP)


func run(delta):
	moveDir = Vector3()
	var cameraBasis = camera.get_global_transform().basis
	if Input.is_action_pressed("up"):
		moveDir -= cameraBasis.z
	elif Input.is_action_pressed("down"):
		moveDir += cameraBasis.z
	if Input.is_action_pressed("left"):
		moveDir -= cameraBasis.x
	elif Input.is_action_pressed("right"):
		moveDir += cameraBasis.x
	
	moveDir.y = 0
	moveDir = moveDir.normalized()
	
	if Vector2(vel.z, vel.x) != Vector2.ZERO:
		global_transform.basis = Basis(Vector3(0, 1, 0), atan2(-vel.z, vel.x))
		animPlayer.play("walk")
#		print ("moving")
	else:
		animPlayer.play("idle")
#		print("stop")
		pass
	
	vel += moveDir * speed * delta


func coverScene(scenePath):
	canMove = false
	generalInGame.isShowingUp = true
	changeScene = scenePath
	animPlayer.play("cover")


func uncoverScene():
	canMove = true
	generalInGame.isShowingUp = false


func sceneChange():
	get_tree().change_scene(changeScene)


func attack():
	state = ATTACK
	animPlayer.play("attack")


func heavyAttack():
	state = ATTACK
	animPlayer.play("heavyAttack")


func specialAttack():
	state = ATTACK
	animPlayer.play("castProjectile")


func castProjectile():
	var b = loadAssets.basicBlast.instance()
	get_tree().get_root().get_node(".").add_child(b)
	b.start(spawnBullet.global_transform)


func beginCharge():
	auraGroundParticles.one_shot = false
	auraGroundParticles.emitting = true
	state = CHARGE_BEGIN
	animPlayer.play("special")
	yield(animPlayer, "animation_finished")
	state = CHARGE


func endParticles():
	auraGroundParticles.one_shot = true
	auraGroundParticles.emitting = false


func backToChargedUp():
	state = CHARGE


func fireQuickBlast():
	animPlayer.playback_speed = 2
	state = CHARGE_FIRE_BLAST
	if isCastedLeft:
		animPlayer.play("fastBlastRight")
		isCastedLeft = false
	else:
		animPlayer.play("fastBlastLeft")
		isCastedLeft = true
	yield(animPlayer, "animation_finished")
	animPlayer.playback_speed = 1


func ultraCharge():
	state = CHARGE_ULTRA_BEGIN
	animPlayer.play("chargeUltra")
	yield(animPlayer, "animation_finished")
	ultraBlastCharge.visible = true
	ultraPivot.visible = true
	state = CHARGE_ULTRA_CHARGE


func chargeBeam(delta):
	chargePower += 5 * delta
	chargePower = clamp(chargePower, 0, 100)
	ultraBlastCharge.mesh.radius += 0.1 * delta
	ultraBlastCharge.mesh.height += 0.1 * 2 * delta
	for n in spots:
		if n is SpotLight:
			n.visible = true
			n.spot_angle = 5
			n.spot_range = 20
			var m = n.get_child(0)
			m.mesh.bottom_radius = spotBeamRadius
			m.mesh.height = spotBeamHeight
	
	ultraBlastCharge.rotate_z(-deg2rad(blastRotX / (chargePower/50) * 5) * delta)
	ultraBlastCharge.rotate_x(deg2rad(0.2))
	
	ultraLight.light_energy = chargePower /10
	ultraLight.omni_range = chargePower /10
	
	ultraBlastCharge.mesh.radius = clamp(ultraBlastCharge.mesh.radius, 0, 1)
	ultraBlastCharge.mesh.height = clamp(ultraBlastCharge.mesh.height, 0, 2)
	

#func castUltraBlast():
#	state = ULTRA_CAST
#	castUltraRelease()
	

func castUltraRelease():
	state = ULTRA_PREPARE_RELEASE
	for n in spots:
		if n is SpotLight:
			tween.interpolate_property(n, "spot_range", n.spot_range, 0, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
			tween.interpolate_property(n, "spot_angle", n.spot_angle, 0, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
			tween.start()
	animPlayer.play("chargeUltraRelease")
	yield(animPlayer, "animation_finished")
#	ultraBlastCharge.visible = false
	ultraBlastCharge.mesh.radius = startingBlastSize
	ultraBlastCharge.mesh.height = startingBlastSize *2
	var k = loadAssets.ultraBlastKame.instance()
	get_tree().get_root().get_node(".").add_child(k)
	k.start(spawnBullet.global_transform, chargePower)
	state = ULTRA_CAST
	chargePower = 0
	ultraLight.light_energy = 0
	ultraLight.omni_range = 0
	ultraBlastCharge.rotation_degrees = Vector3.ZERO


func _beamExploded():
	print("received?")


func signalReceived():
	if state == ULTRA_CAST or state == ULTRA_PREPARE_RELEASE:
		state = MOVE


func backToDefaultState():
	state = MOVE


func _on_Timer_timeout() -> void:
	backToDefaultState()
