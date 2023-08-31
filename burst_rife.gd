extends HitscanGun

class_name BurstRife
var bullet_count = 0
var is_firing = false
var delay_time
@onready var burst_delay = $bullet_shot_delay
@onready var BR_pickup_area = $Pickup_Area
func _init():
	firerate = 4
	ammo = 36
	damage = 20
	weapon_type = 'burst_rife'
	delay_time = 0.5/firerate
	dropped = true
	# Called when the node enters the scene tree for the first time.
	
func _fire(aimcast):
	if ammo>0:
		if Input.is_action_just_pressed("fire"):
			for bullet_count in range(firerate):
				if !is_firing:
					hitscan_fire(aimcast)
					bullet_count +=1
					await get_tree().create_timer(0.05).timeout
				
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dropped == true:
		if Input.is_action_just_pressed("interact"):
			for body in $Pickup_Area.get_overlapping_bodies():
				if body.is_in_group('Player'):
					var player = body
					player.add_weapon(weapon_type)
					set_physics_process(false)
					dropped = false
					queue_free()


func _on_bullet_shot_delay_timeout():
	is_firing = false
