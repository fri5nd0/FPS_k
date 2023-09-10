extends Projectile

class_name Grenade

var damageRaycastArray = []
var directions = []
var readyToBlast = false
var throwSpeed = 2000
@onready var blastTimer = $Blast_timer
func _init():
	damage = 200
# Called when the node enters the scene tree for the first time.
func _ready():
#	directions = _generateDirections(10)
	#if readyToBlast:
	#	_throw()
	#	blastTimer.wait_time = 3.0
	#	blastTimer.start
	pass
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if readyToBlast:
		_apply_forward_impulse(throwSpeed)
		_throw()
func _ProduceRaycasts():
	for dir in directions:
		var raycast = RayCast3D.new()
		raycast.set("transform.origin", Vector3(0, 0, 0)) # Set the origin of the raycast
		raycast.set("cast_to", dir * 20) # Set the direction and length of the raycast
		raycast.set("collision_mask", 1) # Set the collision mask according to your needs
		raycast.build()
		damageRaycastArray.append(raycast)
		add_child(raycast) # Add the raycast as a child of the parent node
		
func _generateDirections(count: int) -> Array:
	var vectors = []
	while len(directions) < count:
		var randomizedDirection = Vector3(randf(),randf(),randf()).normalized()
		vectors.append(randomizedDirection)
		count += 1
	return vectors

func _Blast():
	_ProduceRaycasts()
	for i in damageRaycastArray:
		if i.is_colliding():
			var collision_point = i.get_collision_point()
			var distance = global_transform.origin.distance_to(collision_point)
			var collisionObject = i.get_collider()
			if collisionObject.is_in_group('Player'):
				collisionObject.health -= damage - damage/distance 

func _throw():
	var forward_impulse = transform.basis.z * throwSpeed
	apply_impulse(-transform.basis.z, forward_impulse)

func _on_blast_timer_timeout():
	_Blast()
	
func set_readyToBlast():
	readyToBlast = true
