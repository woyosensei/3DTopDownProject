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


func _on_basicProjectile_body_entered(body: Node) -> void:
	queue_free()
	var p = loadAssets.blastParticles.instance()
	get_tree().get_root().get_node(".").add_child(p)
	p.start(global_transform)
