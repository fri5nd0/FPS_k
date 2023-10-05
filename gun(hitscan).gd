extends Weapon
class_name HitscanGun
signal ammo_count_changed(ammo:int)
@export var weapon_type = 'hitscangun'
func _init():
	ammo = 30
	damage = 100
	dropped = true
	rounds = 3
	ammoRounds = rounds*ammo
@rpc("any_peer")
func _fire(aimcast,Sname):
	if ammo> 0:
		if Input.is_action_just_pressed("fire"):
			hitscan_fire(aimcast,Sname)
func _input(event):
	if Input.is_action_just_pressed('reload'):
		reload(30)
	
@rpc("call_local")
func _process(delta: float) -> void:
	if dropped == true:
		if Input.is_action_just_pressed("interact"):
			for body in $HW_pickup_area.get_overlapping_bodies():
				if body.is_in_group('Player'):
					var player = body
					player.add_weapon.rpc(weapon_type)
					set_physics_process(false)
					dropped = false
					queue_free()
func getAmmoCount() -> int:
	return ammo
	
func hitscan_fire(aimcast,Sname):
		if aimcast.is_colliding():#checks if the ray is colliding with an object
			var target = aimcast.get_collider()
			if target.is_in_group("Player"):#checks if the collision is with a object that is in the group 'enemy'
					print("hit enemy")#just so we know the ray cast is colliding(for test)
					target.doDamage.rpc_id(target.get_multiplayer_authority(),damage,Sname)#reduces player health
			ammo = ammo - 1
		else:
			ammo = ammo -1

			
func updateShooterName(n):
	ShooterName = n


