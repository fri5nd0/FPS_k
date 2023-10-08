extends CharacterBody3D

class_name  Player
signal killed_by(opponent_game_name)
var death_count =0
var kill_count = 0
var health = 200
var speed = 10
var direction = Vector3() # to represent positions in 3D space 
var mouse_sens = 0.05#sets mouse sensitivity
var full_contact = false
var normal_accel = 6
var air_accel = 1
var gravity = 20
var jump = 10
var gravity_direction = Vector3()
var movement = Vector3()
var h_accel = 6
var h_vel = Vector3()
var controller_sens = 1
var weapons =[]
var lastshotby :String
var weapon_dropped
var game_name : int
var is_dead = false
var self_id : int
@onready var gun = $"Head/Gun"
@onready var head = $Head #uses the spatial node 'Head'
@onready var an_pl = $AnimationPlayer
@onready var camera = $Head/Camera3D
@onready var aimcast = $Head/Camera3D/RayCast3D
@onready var Pause = $PauseMenu
@onready var ground_check =$GroundCheck#Uses the ground check raycast node
@onready var player_ui = $CanvasLayer
@onready var holster = $Head/Holster
@onready var AdhesionRay = $Head/Camera3D/ReticleAdhesionRaycast
var weapon_picked
var max_weaps = 3
var ammocount
var isGunOccupied = false
var front_pointer = 0
var rear_pointer = 0
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority():return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED#Captures mouse input events in the window
	camera.current = true
func _process(delta):
	if not is_multiplayer_authority(): return
	ammocount = getAmmoCountFromCurrentGun()
	player_ui.updateAmmoCount(ammocount)
	player_ui.lastShotbyLabel(lastshotby)
	player_ui.healthLabel(health)
	var players = get_parent().getPlayerNames()
#	var gameName = players[int(str(name))]
	var axis_vector = Vector2()
	axis_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	if InputEventJoypadMotion:
				rotate_y(deg_to_rad(-axis_vector.x) * controller_sens)
				head.rotate_x(deg_to_rad(-axis_vector.y) * controller_sens)
				head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
				if aimcast.is_colliding():
					var body = aimcast.get_collider()
					if body.is_in_group('Player'):
						reticleFriction(30,axis_vector.x,axis_vector.y)
				if AdhesionRay.is_colliding():
					var StickyArea = AdhesionRay.get_collider()
					if StickyArea.is_in_group('AdhesionArea'):
						ApplyReticleAdhesion(StickyArea)
	if health <= 0 and is_dead== false:
		_after_death.rpc()	
		is_dead = true

func _input(event):
	if not is_multiplayer_authority():return
	if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
func _unhandled_input(event):
	if not is_multiplayer_authority():return
	if event.is_action_pressed("Pause"):
			Pause.is_paused = !Pause.is_paused

func _physics_process(delta):
	if not is_multiplayer_authority():return
					
	if gun.get_child_count() > 0:
			var in_hand = gun.get_child(0)
			if Input.is_action_just_pressed("fire"):#checks if moouse button is clicked
				in_hand._fire(aimcast,name)
			
	direction = Vector3()
			
	full_contact = ground_check.is_colliding()
		
	if Input.is_action_just_pressed('swap'):
			if holster.get_child_count()>0:
				swapWeapon.rpc()
			
	if not is_on_floor():
			gravity_direction += Vector3.DOWN * gravity * delta#Gravity acts vertically, downwards when not on floor
			h_accel = air_accel
	elif is_on_floor():
			gravity_direction = Vector3.DOWN
			h_accel = normal_accel
				
	if Input.is_action_just_pressed("Jump") and (is_on_floor() or ground_check.is_colliding()):
			gravity_direction = Vector3.UP * jump # Jump action, gravity vector acts upwards in the magnitude of 'jump'
				
	if Input.is_action_pressed("move_forward"):
			direction -= transform.basis.z#when the move forward button is pressed, the direction of movement
				#would be the direction the player facing(Z axis)
	if Input.is_action_pressed("move_back"):# Opposite to the direction the player is facing
			direction += transform.basis.z
	if Input.is_action_pressed("move_left"):#To the left in X axis
				direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):# To the right
			direction += transform.basis.x
	if Input.is_action_just_pressed("Test_self_destruct"):
		health = 0
	if Input.is_action_just_pressed("drop_weapon"):
		dropWeapon()
				
	direction = direction.normalized()#prevents player from going faster diagonally
			
			
	h_vel = h_vel.lerp(direction*speed,h_accel*delta)# allows player to accelerate and decelerate realistically instead of stopping right away
	movement.z = h_vel.z + gravity_direction.z# resultant of the horizontal velocity and the gravity vector in the z axis
	movement.x = h_vel.x + gravity_direction.x# x axis
	movement.y = gravity_direction.y
	set_velocity(movement)
	set_up_direction(Vector3.UP)
	move_and_slide() #If the body collides with another, it will slide along the other body rather than stop immediately

@rpc("call_local",'any_peer')
func add_weapon(weapon_type):
		if weapons.size()< max_weaps:
			var weapon_scene = load("res://" + weapon_type + ".tscn")
			# Check if the weapon scene is already a child of gun or holster
			if !gun.has_node(weapon_type) and !holster.has_node(weapon_type):
				var weapon_instance = weapon_scene.instantiate()
				if !isGunOccupied:
					gun.add_child(weapon_instance)
					isGunOccupied = true
					weapons.append(weapon_type)
				elif holster.get_child_count()< 2:
					var current_gun = gun.get_child(0)
					gun.remove_child(current_gun)
					holster.add_child(current_gun)
					gun.add_child(weapon_instance)
					rear_pointer += 1
					weapons.append(weapon_type)
				elif holster.get_child_count()==2:
					var current_gun = gun.get_child(0)
					gun.remove_child(current_gun)
					gun.add_child(weapon_instance)
					weapons.append(weapon_type)

@rpc("call_local")
func swapWeapon():
	var holsterWeapons = holster.get_children()
	var currentGun = gun.get_child(0)
	if holsterWeapons.size() < 2:
		var gunWanted =  holster.get_child(0)
		gun.remove_child(currentGun)
		holster.remove_child(gunWanted)
		gun.add_child(gunWanted)
		holster.add_child(currentGun)
	if holsterWeapons.size()>=2:
		var gunWanted = holster.get_child(front_pointer)
		gun.remove_child(currentGun)
		holster.remove_child(gunWanted)
		gun.add_child(gunWanted)
		holster.add_child(currentGun)
		if front_pointer == 0:
			front_pointer +=1
		else:
			front_pointer = 1
		if rear_pointer == 1:
			rear_pointer = 0
		else:
			rear_pointer = 1

func dropWeapon():
	var gunToDrop = gun.get_child(0)
	gun.remove_child(gunToDrop)
	var dropPos = global_transform.origin
	gunToDrop.transform.origin(dropPos)
	get_parent().add_child(gunToDrop)
	
func getAmmoCountFromCurrentGun() -> int:
	if gun.get_child_count() > 0:
		var gunNode = gun.get_child(0)
		return gunNode.getAmmoCount()
	else:
		return 0
@rpc("call_local")
func _after_death():
	death_count +=1
	get_parent().changeScore.rpc(lastshotby, name)
	if gun.get_child_count()!= 0:
		for child in gun.get_children():
			gun.remove_child(child)
		for child in holster.get_children():
			holster.remove_child(child)
	transform.origin = Vector3(45.725,34.739,0)
	killed_by.emit(lastshotby)
	await get_tree().create_timer(5).timeout
	is_dead = false
	transform.origin = _getSpawnPoint()
	health = 200
	
func _getSpawnPoint():
	var safeSpawn
	var safeQuad = get_parent().findSafeSpawn()
	if safeQuad == 1:
		return Vector3(-15,1,9)
	if safeQuad == 2:
		return Vector3(15,1,9)
	if safeQuad == 3:
		return Vector3(15,1,-9)
	if safeQuad == 4:
		return Vector3(-15,1,-9)
	else:
		return Vector3(0,0,0)

func _recieveDamage(damage):
	health -= damage
@rpc('any_peer')
func doDamage(damage,lsb):
	_recieveDamage(damage)
	setlastshotby(lsb)

func reticleFriction(friction_value,x,y):
	rotate_y(deg_to_rad(-x) * controller_sens*friction_value)
	head.rotate_x(deg_to_rad(-y) * controller_sens*friction_value)
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func setlastshotby(lsb):
	lastshotby = lsb
	player_ui.lastShotbyLabel(lastshotby)

func ApplyReticleAdhesion(StickyArea: Area3D):
	if AdhesionRay.is_colliding() and StickyArea and StickyArea.is_in_group('AdhesionArea'):
		AdhesionRay.look_at(StickyArea.global_transform.origin)
