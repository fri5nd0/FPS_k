extends ProjectileWeapon

class_name Grenade_launcher

# Called when the node enters the scene tree for the first time.
@onready var GL_PickupArea = $PW_pickup_area
func _init():
	ammo = 20
	dropped = true
	weapon_type = 'grenade_launcher'
# Called when the node enters the scene tree for the first time.
func _ready():
	muzzle = $Muzzle

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if dropped == true:
			pickupWeapon(GL_PickupArea)
func _fire(aimcast,Sname):
	if  ammo > 0:
		projectile_fire(aimcast,Sname)
		ammo -= 1


func projectile_fire(aimcast,Sname):
	var Projectile = preload("res://grenadee.tscn")
	if aimcast.is_colliding():
		var target = aimcast.get_collider()
		var projectile = Projectile.instantiate()
		muzzle.add_child(projectile)
		projectile.look_at(aimcast.get_collision_point(), Vector3.UP)
		projectile.readyToBlast = true
		projectile.setShooterName(Sname)
func getAmmoCount():
	return ammo
