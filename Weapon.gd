extends RigidBody3D

class_name Weapon

var damage:int 
var firerate: int
var ammo:int
var rounds:int
var dropped:bool
var ShooterName
var ammoRounds
@export var weapon_type :String
func reload(ogAmmo):
	if ammoRounds:
		var ammoDeficit = ogAmmo-ammo
		if ammoRounds >= ogAmmo:
			ammoRounds -= ammoDeficit
			ammo = ogAmmo
		if ammoRounds < ogAmmo:
			ammo = ammoRounds
			ammoRounds = 0
			

@rpc("any_peer","call_local")
func pickupWeapon(PickupArea):
	if PickupArea is Area3D:
		for body in PickupArea.get_overlapping_bodies():
			if body.is_in_group('Player'):
				var player = body
				player.add_weapon.rpc(weapon_type)
				set_physics_process(false)
				dropped = false
				queue_free()
