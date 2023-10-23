extends Weapon

class_name ProjectileWeapon

@onready var muzzle = $Muzzle

@onready var PickupArea = $PW_pickup_area
var fire_rate = 0.5
var can_fire = true
func _init():
	ammo = 20
	dropped = true
	rounds = 2
	ammoRounds = ammo*rounds
	weapon_type = 'projectile_weapon'
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
func _input(event):
	if Input.is_action_just_pressed('reload'):
		reload(20)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if dropped == true:
			pickupWeapon(PickupArea)
func _fire(aimcast, Sname):
	if  ammo > 0:
		projectile_fire(aimcast,Sname)
		ammo -= 1

func projectile_fire(aimcast,Sname):
	var Projectile = preload("res://Projectile.tscn")
	if aimcast.is_colliding():
		var target = aimcast.get_collider()
		var projectile = Projectile.instantiate()
		muzzle.add_child(projectile)
		projectile.look_at(aimcast.get_collision_point(), Vector3.UP)
		projectile.shoot = true
		projectile.setShooterName(Sname)
		

func getAmmoCount():
	return ammo
