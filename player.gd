extends CharacterBody3D

class_name  Player

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
var weapon_dropped 
@onready var gun = $"Head/Gun"
@onready var head = $Head #uses the spatial node 'Head'
@onready var an_pl = $AnimationPlayer
@onready var camera = $Head/Camera3D
@onready var aimcast = $Head/Camera3D/RayCast3D
@onready var Pause = $PauseMenu
@onready var ground_check =$GroundCheck#Uses the ground check raycast node
@onready var player_ui = $CanvasLayer
@onready var holster = $Head/Holster
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
	print(ammocount)
	player_ui.updateAmmoCount(ammocount)
	var axis_vector = Vector2()
	axis_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	if InputEventJoypadMotion:
				rotate_y(deg_to_rad(-axis_vector.x) * controller_sens)
				head.rotate_x(deg_to_rad(-axis_vector.y) * controller_sens)
				head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
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
				in_hand._fire(aimcast)
			
	direction = Vector3()
			
	full_contact = ground_check.is_colliding()
		
	if Input.is_action_just_pressed('swap'):
			if holster.get_child_count()>0:
				swapWeapon()
			
	if not is_on_floor():
			gravity_direction += Vector3.DOWN * gravity * delta#Gravity acts vertically, downwards when not on floor
			h_accel = air_accel
	elif is_on_floor():
			gravity_direction = -get_floor_normal()
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
				
	direction = direction.normalized()#prevents player from going faster diagonally
			
			
	h_vel = h_vel.lerp(direction*speed,h_accel*delta)# allows player to accelerate and decelerate realistically instead of stopping right away
	movement.z = h_vel.z + gravity_direction.z# resultant of the horizontal velocity and the gravity vector in the z axis
	movement.x = h_vel.x + gravity_direction.x# x axis
	movement.y = gravity_direction.y
	set_velocity(movement)
	set_up_direction(Vector3.UP)
	move_and_slide() #If the body collides with another, it will slide along the other body rather than stop immediately

func add_weapon(weapon_type):
		if weapons.size()< max_weaps:
			weapons.append(weapon_type)
			var weapon_scene = load("res://" + weapon_type + ".tscn")
			# Check if the weapon scene is already a child of gun or holster
			if !gun.has_node(weapon_type) and !holster.has_node(weapon_type):
				var weapon_instance = weapon_scene.instantiate()
				if !isGunOccupied:
					gun.add_child(weapon_instance)
					isGunOccupied = true
				elif holster.get_child_count()<= 2:
					var current_gun = gun.get_child(0)
					gun.remove_child(current_gun)
					holster.add_child(current_gun)
					gun.add_child(weapon_instance)
					rear_pointer += 1
				else:
					print('cant pick up')


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

func getAmmoCountFromCurrentGun() -> int:
	if gun.get_child_count() > 0:
		var gunNode = gun.get_child(0)
		return gunNode.getAmmoCount()
	else:
		return 0
