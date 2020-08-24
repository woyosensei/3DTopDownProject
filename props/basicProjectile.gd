extends Area


var speed = 50
var velocity = Vector3()


func start(dir):
	transform = dir
	velocity = transform.basis.x * speed


func _physics_process(delta: float) -> void:
	transform.origin += velocity * delta


func _on_Timer_timeout() -> void:
	queue_free()
	var p = loadAssets.blastParticles.instance()
	get_tree().get_root().get_node(".").add_child(p)
	p.start(global_transform)
	spawnBlast()


func _on_basicProjectile_body_entered(body: Node) -> void:
	queue_free()
	var p = loadAssets.blastParticles.instance()
	get_tree().get_root().get_node(".").add_child(p)
	p.start(global_transform)
	spawnBlast()
	if body is RigidBody:
		body.apply_impulse(Vector3(0, 0 ,0), global_transform.origin)


func spawnBlast():
	var b = preload("res://props/projectileBlastRadius.tscn").instance()
	get_tree().get_root().get_node(".").add_child(b)
	b.transform = global_transform
