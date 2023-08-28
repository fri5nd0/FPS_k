extends Weapon

class_name ProjectileWeapon

@onready var muzzle = $Muzzle

var fire_rate = 0.5
var can_fire = true
var weapon_type = 'projectile_weapon'
func _init():
	ammo = 20
	dropped = true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

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
	var Projectile = preload("res://Projectile.tscn")
	if aimcast.is_colliding():
		var target = aimcast.get_collider()
		var projectile = Projectile.instantiate()
		muzzle.add_child(projectile)
		projectile.look_at(aimcast.get_collision_point(), Vector3.UP)
		projectile.shoot = true

func getAmmoCount():
	return ammo
