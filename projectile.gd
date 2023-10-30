extends RigidBody3D

class_name Projectile

var shoot = false
var damage = 100
var speed = 100  
const deceleration = 0.05
const gravitationalStrength = 0.098
var Sname :String
@onready var collisionR = $RayCast3D
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
	if collisionR.is_colliding():
		# Get the collision information
		var collision = collisionR.get_collider()
		var collision_point = collisionR.get_collision_point()
		var collision_normal = collisionR.get_collision_normal()
		# Check if we have a valid collision normal, and if not, calculate it
		if collision_normal.length_squared() < 0.01:
			collision_normal = GetCollisionNormal(global_transform.origin, collision_point)
		# Reflect the velocity
		var current_velocity = linear_velocity
		var new_velocity = current_velocity.bounce(collision_normal)
		linear_velocity = new_velocity
		# Adjust speed and damage
		speed *= 0.8
		damage *= 0.8

func GetCollisionNormal(ray_origin, ray_collision_point):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_collision_point)
	var result = space_state.intersect_ray(query)
	if result.collider:
		return result.normal.normalized()
#	else:
		# If no collision is found, return a default value (you can adjust this as needed)
#		return Vector3(0, 1, 0)
