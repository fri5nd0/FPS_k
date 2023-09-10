extends ProjectileWeapon

class_name Grenade_launcher

# Called when the node enters the scene tree for the first time.

func _init():
	ammo = 20
	dropped = true
	weapon_type = 'grenade_launcher'
# Called when the node enters the scene tree for the first time.
func _ready():
	muzzle = $Muzzle

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dropped == true:
		if Input.is_action_just_pressed("interact"):
			for body in $PW_pickup_area.get_overlapping_bodies():
				if body.is_in_group('Player'):
					var player = body
					player.add_weapon(weapon_type)
					set_physics_process(false)
					dropped = false
					queue_free()
func _fire(aimcast):
	if  ammo > 0:
		projectile_fire(aimcast)
		ammo -= 1


func projectile_fire(aimcast):
	var Projectile = preload("res://grenadee.tscn")
	if aimcast.is_colliding():
		var target = aimcast.get_collider()
		var projectile = Projectile.instantiate()
		muzzle.add_child(projectile)
		projectile.look_at(aimcast.get_collision_point(), Vector3.UP)
		projectile.readyToBlast = true

func getAmmoCount():
	return ammo
