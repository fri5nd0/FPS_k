extends CharacterBody3D

var health = 200

func _ready():
	pass

@rpc("call_local")
func _process(delta):
	if health <= 0:
		queue_free()
	
