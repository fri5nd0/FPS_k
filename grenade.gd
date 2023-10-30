extends Projectile

class_name Grenade
var isMoving = true
var readyToBlast = false
var blastTimer = 0
var blastTime= 2
var collisionCounter = 0
@onready var damageCheck = $damageCheck
func _init():
	damage = 200
	speed = 10
# Called when the node enters the scene tree for the first time.
func _ready():
		set_as_top_level(true)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if isMoving == true:
		_apply_forward_impulse()
		_apply_gravity()
		_decelerate()
	blastTimer += delta
	if blastTimer >= blastTime:
		_Blast()
func _Blast():
	var hitEnemy = false  # Flag to track if an enemy was hit
	for body in $BlastSphere.get_overlapping_bodies():
		if body != self:
			var target = body 
			if target.is_in_group('Player'):
				var space = get_world_3d().direct_space_state
				var query = PhysicsRayQueryParameters3D.create(global_transform.origin,body.global_transform.origin)
				var collision = space.intersect_ray(query)
				var distance_to_collider = collision.position - global_transform.origin
				var distance = distance_to_collider.length()  # This gives you the distance # This gives you the distance
				if collision.collider.is_in_group('Player'):
					var damageFactor = 1/(distance*distance)
					damage = damage*damageFactor
					target.doDamage.rpc_id(target.get_multiplayer_authority(), damage, Sname)
					hitEnemy = true  # Set the flag to indicate that an enemy was hit
	queue_free()

func _on_collision_area_body_entered(body):
	collisionCounter += 1
	if collisionCounter >= 3:
		isMoving = false
	ProjectileRicochet()
