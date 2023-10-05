extends Player

var target
func _process(delta):
	move_and_slide()
	if target:
		look_at(target.global_transform.origin, Vector3.UP)
func _physics_process(delta):
	pass
	
func _on_area_3d_body_entered(body):
	if body.is_in_group('Player'):
		target = body
		

func _on_area_3d_body_exited(body):
	if body.is_in_group('Player'):
		target = body


