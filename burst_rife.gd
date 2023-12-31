extends HitscanGun

class_name BurstRife
var bullet_count = 0
var is_firing = false
var delay_time
@onready var burst_delay = $bullet_shot_delay
@onready var BR_PickupArea = $Pickup_Area

func _init():
	firerate = 4
	ammo = 36
	damage = 20
	weapon_type = 'burst_rife'
	delay_time = 0.5/firerate
	dropped = true
	rounds = 3
	ammoRounds = ammo*rounds
	# Called when the node enters the scene tree for the first time.

func _input(event):
	if Input.is_action_just_pressed('reload'):
		reload(36)
	
func _fire(aimcast,Sname):
	if ammo>0:
		if Input.is_action_just_pressed("fire"):
			for bullet_count in range(firerate):
				if !is_firing:
					hitscan_fire(aimcast,Sname)
					bullet_count +=1
					await get_tree().create_timer(0.05).timeout
				
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@rpc("any_peer")
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if dropped == true:
			pickupWeapon(BR_PickupArea)

func _on_bullet_shot_delay_timeout():
	is_firing = false
