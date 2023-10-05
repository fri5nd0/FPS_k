extends RigidBody3D

class_name Weapon

var damage:int 
var firerate: int
var ammo:int
var rounds:int
var dropped:bool
var ShooterName
var ammoRounds
			
func reload(ogAmmo):
	if ammoRounds:
		var ammoDeficit = ogAmmo-ammo
		if ammoRounds >= ogAmmo:
			ammoRounds -= ammoDeficit
			ammo = ogAmmo
		if ammoRounds < ogAmmo:
			ammo = ammoRounds
			ammoRounds = 0
