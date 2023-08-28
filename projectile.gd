extends RigidBody3D
class_name Projectile

var shoot = false
var damage = 100
const speed = 100  # Adjust this value for the initial speed of the projectile (in m/s)
const deceleration = 0.1  # Adjust this value for the deceleration rate (in N)
const gravitationalStrength = 9.8  # Adjust this value for the gravitational strength (in N)

func _ready():
	set_as_top_level(true)

func _physics_process(delta):
	if shoot:
		_apply_forward_impulse()
		#_decelerate()
		#_apply_gravity()

func _apply_forward_impulse():
	var forward_impulse = transform.basis.z * speed
	apply_impulse(-transform.basis.z, forward_impulse)

func _decelerate():
	var current_velocity = linear_velocity
	var deceleration_force = -current_velocity.normalized() * deceleration
	apply_central_impulse(deceleration_force)

func _apply_gravity():
	var gravityVector = Vector3(0, -gravitationalStrength, 0)
	apply_central_impulse(gravityVector)

func _on_damage_area_body_exited(body):
	if body.is_in_group('Player'):
		
		body.health -= damage
		queue_free()
