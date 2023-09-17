extends HitscanGun

class_name Sniper

var can_fire := true
var fire_cooldown := 1
func _init():
	ammo = 10
	damage = 200
	firerate = 1
	dropped = true
	weapon_type = 'sniper'
	
func _fire(aimcast):
	if ammo > 0 and can_fire:
		if Input.is_action_just_pressed("fire"):
			super.hitscan_fire(aimcast)
			can_fire = false
			$Timer.start(fire_cooldown)
func _ready():
	pass

func _process(delta):
	pickupWeapon()
func pickupWeapon():
	if dropped == true:
		if Input.is_action_just_pressed("interact"):
			for body in $PickUpArea.get_overlapping_bodies():
				if body.is_in_group('Player'):
					var player = body
					player.add_weapon.rpc(weapon_type)
					set_physics_process(false)
					dropped = false
					queue_free()

func _on_timer_timeout():
	can_fire = true
