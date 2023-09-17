extends Projectile

class_name Grenade

var readyToBlast = false
@onready var blastTimer = $Blast_timer
@onready var damageCheck = $damageCheck
func _init():
	damage = 200
	speed = 1000
# Called when the node enters the scene tree for the first time.
func _ready():
		set_as_top_level(true)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if readyToBlast:
		_apply_forward_impulse()
		_Blast()
func _Blast():
	await get_tree().create_timer(5).timeout
	for body in $BlastSphere.get_overlapping_bodies():
		if body != self:
			var direction = (body.global_transform.origin - global_transform.origin).normalized()
			damageCheck.look_at(body.global_transform.origin + direction)
			if damageCheck.is_colliding():
				var target = damageCheck.get_collider()
				if target.is_in_group('Player'):
					target.health -= damage
					queue_free()
				else:
					pass
					
func _apply_forward_impulse():
	var forward_direction = -transform.basis.z  # Opposite of the forward direction
	var forward_velocity = forward_direction * speed
	var upward_velocity = Vector3(0, 1, 0) * speed  # Adjust the Y value for the desired arc height
	var total_velocity = forward_velocity + upward_velocity
	apply_impulse(Vector3.ZERO, total_velocity)
