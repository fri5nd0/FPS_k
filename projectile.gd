extends RigidBody3D

class_name Projectile

var shoot = false
var damage = 100
var speed = 100  
const deceleration = 0.05
const gravitationalStrength = 0.098
var Sname :String
@onready var collisonR = $RayCast3D
func _ready():
	set_as_top_level(true)

func _physics_process(delta):
	if shoot:
		_apply_forward_impulse()
		await get_tree().create_timer(0.1).timeout
		_decelerate()
		_apply_gravity()

func _apply_forward_impulse():
	var forward_impulse = transform.basis.z * speed
	apply_impulse(-transform.basis.z, forward_impulse)

func _decelerate():
	var current_velocity = linear_velocity
	var deceleration_force = -current_velocity.normalized() * deceleration
	apply_impulse(Vector3(0, 0, 0), deceleration_force)


func _apply_gravity():
	var gravityVector = Vector3.DOWN * Vector3(0, gravitationalStrength, 0)
	apply_central_impulse(gravityVector)

func setShooterName(ShooterName):
	Sname = ShooterName

func _on_damage_area_body_entered(body):
	if body.is_in_group('Player'):
		body.doDamage.rpc_id(body.get_multiplayer_authority(),damage,Sname)
	else:
		ProjectileRicochet()
func ProjectileRicochet():
	var collisionVector = GetCollisionVector().normalized()
	var currentVelocity = linear_velocity
	var newVelocity = -currentVelocity.reflect(collisionVector)
	linear_velocity = newVelocity
	speed *= 0.8
	damage *= 0.8

func GetCollisionVector():
	if collisonR.is_colliding():
		var CollisionPoint = collisonR.get_collision_point()
		var collisionObject = collisonR.get_collider()
		var rayOrigin = collisonR.global_transform.origin
		var collisionNormal = (CollisionPoint - collisionObject.global_transform.origin).normalized()#GetCollisionNormal(rayOrigin,CollisionPoint)#
		if collisionNormal:
			return collisionNormal
	else: 
		return Vector3(1/2,0,sqrt(3)/2)

func GetCollisionNormal(RayOrigin,RayCollisonPoint):
	var spaceState = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = RayOrigin
	params.to = RayCollisonPoint
	params.exclude = []
	params.collision_mask = 1
	var result = spaceState.intersect_ray(params)
	return result
