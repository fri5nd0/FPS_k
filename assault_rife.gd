extends HitscanGun

class_name AssaultRifle

var is_firing = false
var shot_delay : int 
@onready var AR_PickupArea = $Pickup_area
func _init():
	damage = 30
	ammo = 40
	dropped = true
	firerate = 7
	weapon_type = 'assault_rife'
	shot_delay = 1/firerate
	rounds = 4
	ammoRounds = ammo*rounds
func _input(event):
	if Input.is_action_just_pressed('reload'):
		reload(40)
func _ready():
	$Firerate_timer.one_shot = false

func _fire(aimcast,Sname):
	if ammo > 0:
		if Input.is_action_pressed("fire"):
			if !is_firing:
				is_firing = true
				hitscan_fire(aimcast,Sname)
				$Firerate_timer.start(shot_delay)


func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if dropped == true:
			pickupWeapon(AR_PickupArea)


func _on_firerate_timer_timeout():
	is_firing = false
