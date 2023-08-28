extends HitscanGun

class_name AssaultRifle

var is_firing = false
var shot_delay : int 
func _init():
	damage = 30
	ammo = 40
	dropped = true
	firerate = 7
	weapon_type = 'assault_rife'
	shot_delay = 1/firerate

func _ready():
	$Firerate_timer.one_shot = false
	
func _fire(aimcast):
	if ammo > 0:
		if Input.is_action_pressed("fire"):
			if !is_firing:
				is_firing = true
				hitscan_fire(aimcast)
				$Firerate_timer.start(shot_delay)


func _process(delta):
	if dropped == true:
		if Input.is_action_just_pressed("interact"):
			for body in $Pickup_area.get_overlapping_bodies():
				if body.is_in_group('Player'):
					var player = body
					player.add_weapon(weapon_type)
					set_physics_process(false)
					dropped = false
					queue_free()


func _on_firerate_timer_timeout():
	is_firing = false