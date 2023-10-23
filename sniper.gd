extends HitscanGun

class_name Sniper

var can_fire := true
var fire_cooldown := 1

@onready var SR_PickupArea = $PickUpArea
func _init():
	ammo = 10
	damage = 200
	firerate = 1
	dropped = true
	weapon_type = 'sniper'
	rounds = 2
	ammoRounds = ammo*rounds
func _input(event):
	if Input.is_action_just_pressed('reload'):
		reload(10)
		
func _fire(aimcast,Sname):
	if ammo > 0 and can_fire:
		if Input.is_action_just_pressed("fire"):
			super.hitscan_fire(aimcast,Sname)
			can_fire = false
			$Timer.start(fire_cooldown)
func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if dropped == true:
			pickupWeapon(SR_PickupArea)

func _on_timer_timeout():
	can_fire = true
