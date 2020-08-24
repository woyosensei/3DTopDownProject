extends Spatial


onready var beam = $beam
onready var blast = $blast
onready var tween = $Tween
onready var timer = $Timer

var growing = true
var beamGone = false
var blastGone = false
var isExploded = false

var startingRadius

var speed = 20
var blastSize = Vector3(1, 1, 1)
var blastRadiusMultiplier = 5

var beamStartRadius = 1
var beamStartHeight = 0.001

var player


func start(pos, eng):
	var energy = eng / 100
	backToNormal(energy)
	transform = pos
	player = generalInGame.player


func _process(delta: float) -> void:
#	if $Particles.amount < 1: $Particles.amount = 1
	
	if growing:
		beam.mesh.mid_height += speed * delta
		beam.translation.x = (beam.mesh.mid_height /2) - beam.mesh.radius
		blast.translation.x += speed * delta
	if not growing:
		if beamGone == false:
			if beam.get_surface_material(0).albedo_color.a >= 0:
				beam.get_surface_material(0).albedo_color.a -= 0.8 * delta
			else:
				beam.get_surface_material(0).albedo_color.a = 0
		beamGone(delta)
		if blastGone == false:
			blast.get_surface_material(0).flags_transparent = true
			if blast.get_surface_material(0).albedo_color.a > 0:
				blast.get_surface_material(0).albedo_color.a -= 0.5 * delta
			else:
				blastGone = true
				$beamAuraEffect.queue_free()
				blast.queue_free()
			blast.rotate_y(deg2rad(3))
			
		
		

func blowUp(delta):
	growing = false
	beamGone(delta)
	detonate()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ultra"):
		$selfDestruct.stop()
		if growing:
			growing = false
			if isExploded == false:
				detonate()
				isExploded = true
		

func beamGone(delta):
	if beamGone == false:
		beam.mesh.radius -= (beamStartRadius /2) * delta
		if beam.mesh.radius <= 0:
#			beam.queue_free()
			beamGone = true
		

func detonate():
	
	if blastGone == false:
		var spat = $beamAuraEffect.get_children()
		for p in spat:
			if p is Particles:
				tween.interpolate_property(p, "amount", p.amount, 1, 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.interpolate_property($beamAuraEffect/OmniLight, "omni_range", $beamAuraEffect/OmniLight.omni_range, 0, 2, Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.interpolate_property($beamAuraEffect/OmniLight, "light_energy", $beamAuraEffect/OmniLight.light_energy, 0, 2, Tween.TRANS_EXPO, Tween.EASE_OUT)
	if blast:
		tween.interpolate_property($blast/OmniLight, "light_energy", $blast/OmniLight.light_energy, 10, 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.interpolate_property($blast/OmniLight, "omni_range", $blast/OmniLight.omni_range, 30, 0.5,Tween.TRANS_EXPO,Tween.EASE_OUT)
		tween.interpolate_property(blast, "scale", blastSize, blastSize * 5, 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
#	tween.interpolate_property($Particles, "amount", $Particles.amount, 1, 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
#	tween.interpolate_property($Particles/OmniLight, "omni_range", $Particles/OmniLight.omni_range, 0, 2, Tween.TRANS_EXPO, Tween.EASE_IN)
#	tween.interpolate_property($Particles/OmniLight, "light_energy", $Particles/OmniLight.light_energy, 0, 2, Tween.TRANS_EXPO, Tween.EASE_IN)
	tween.start()
	timer.start(3)
#	if $Particles.amount < 1: $Particles.amount = 1
	

func backToNormal(eng):
	blast.mesh.radius = eng * blastRadiusMultiplier
	blast.mesh.height = blast.mesh.radius * 2
	blast.scale = blastSize
	blast.get_surface_material(0).albedo_color.a = 1
	blast.get_surface_material(0).flags_transparent = false
	
	beam.mesh.radius = eng
	beam.translation.x = beam.mesh.radius
	beamStartRadius = beam.mesh.radius
	beam.mesh.mid_height = beamStartHeight
	beam.get_surface_material(0).albedo_color.a = 1
	
#	$Particles.amount = floor((eng * blastRadiusMultiplier * 5) * 100)


func _on_Area_body_entered(body: Node) -> void:
	growing = false
	detonate()


func _on_Timer_timeout() -> void:
	queue_free()
	var send = get_tree().get_current_scene().find_node("player")
	if send:
		send.signalReceived()
#	free()


func _on_selfDestruct_timeout() -> void:
	growing = false
	detonate()

