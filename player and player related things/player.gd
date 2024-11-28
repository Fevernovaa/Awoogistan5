extends CharacterBody3D

var fall_multiplier : float = 2.8 #when falling, multiply this by gravity
var JUMP_VELOCITY : float = 12
var rotation_x: float = 0 #set later
var rotation_y: float = 0 #set later
@onready var camera : Camera3D = $Camera3D #reference to the camera
var can_jump : bool = false #check
var can_airdash : bool = false #check
@onready var raycast1 : RayCast3D = $GroundDetectionRaycast #ground detection raycast, is_on_floor() is unreliable
var direction4 : Vector3 #Vector3 for the force applied while wall running
var floorcheck : bool #check
var wallnormal #set later
var SPEED #set later, reason below

# PSA
# you can use both static and dynamic typing
# static typing is faster ofc
# dynamic typing is x = 5.5
# static typing is x : float = 5.5
# there's also x := 5.5 but i don't know how it differs from just doing =
# but its still faster than just doing = 
#
# basiclly if you know the type, do : TYPE =
# if you don't, do :=
# if it throws an error, do =

#p.s. "ui_accept" is space

#quick recap
#


func _physics_process(delta: float) -> void:
	SPEED = 8 * 1.8# the speed is assigned here because it needs to reset back to the default value
				  # every frame, because when sprinting the value of speed is changed
	
	var input_dir := Input.get_vector("A", "D", "W", "S")#i don't know what this does
	var direction := (camera.transform.basis.x * input_dir.x + camera.transform.basis.z * input_dir.y)
	# assigns "direction" the vectors of my input, W is a forward/upwards vector for example
	direction.y = 0 # makes sure looking up and down doesn't affect direction
	direction = direction.normalized()
	
	floorcheck = raycast1.is_colliding() # floor check
	
	
	if floorcheck: 
		# if on the ground, move normally, the calculation makes it so
		# the player accelerates gradually, the accleration is controlled by this number
		velocity.x += (direction.x * SPEED - velocity.x) * 0.2 #<<<<<<<<<<<<
		velocity.z += (direction.z * SPEED - velocity.z) * 0.2 #<<<<<<<<<<<<
		can_jump = true #if the player touches the ground, allow them to jump again
		can_airdash = true #same but with the air dash
		if Input.is_action_pressed("ui_accept") and can_jump == true:
			jump()
		
	elif floorcheck and direction == Vector3.ZERO: 
		# if on the ground and not pressing movement buttons, make the player stop gradually
		# how fast the player stops is controlled by this number
		velocity.x += -velocity.x * 0.03 #<<<<<<<<<<<
		velocity.z += -velocity.z * 0.03 #<<<<<<<<<<<
		can_jump = true
		can_airdash = true
		# need to write the code twice because only 1 code block can be executed
		# due to the if/elif statements
		if Input.is_action_pressed("ui_accept") and can_jump == true:
			jump()
		
	elif !floorcheck:
		# if the player is in the air, allow them to move but with much less control
		# the control the player has while in the air is controlled by this number
		velocity.x += (direction.x * SPEED - velocity.x) * 0.03 #<<<<<<<<<
		velocity.z += (direction.z * SPEED - velocity.z) * 0.03 #<<<<<<<<<
		
		
		gravity3(delta)#explained below
		
		
		if is_on_wall(): #wall ride function
			if velocity.length() > 8: #wall riding only depends on the player's speed
									  #doesn't have any other checks
									  #other than the playing being mid-air
				direction4 = wall_ride(SPEED,direction)                  #explained below
				if Input.is_action_just_pressed("ui_accept"):
					jump_off_wall(direction4)        #explained below
			else:
				gravity3(delta)
		else:
			if Input.is_action_just_pressed("ui_accept") and can_airdash == true:
				air_dash(direction,SPEED)                      #explained below
				can_airdash = false
			
		
	move_and_slide()

func jump():
	can_jump = false
	velocity.y += JUMP_VELOCITY
	#jumps, hardest thing to understand here

func air_dash(direction,SPEED):
	if direction != Vector3.ZERO:
		velocity.y += JUMP_VELOCITY / 5
		velocity.x += (direction.x * SPEED * 1.2)
		velocity.z += (direction.z * SPEED * 1.2)
		#small vertical movement and a large horizontal movement
	else:
		velocity.y += JUMP_VELOCITY / 5
		velocity.z += (-1 * SPEED * 1.2)
		#if the play has no inputs, the air dash is forward
		# -1 in the z means forward btw

func jump_off_wall(direction4):
	velocity.y += JUMP_VELOCITY * 1.3
	velocity.x -= direction4.x
	velocity.z -= direction4.z
	#apply force opposite of the direction of the wall, 
	#difference between this and the wall ride function is i used -= instead of +=
	#direction4 is the direction towards the wall 
	

func wall_ride(SPEED,direction):
	wallnormal = get_slide_collision(0)
	direction4 = -wallnormal.get_normal() * SPEED
	velocity.x += (direction4.x - velocity.x) * 0.01
	velocity.z += (direction4.z - velocity.z) * 0.01
	velocity.x += direction.x * 0.50
	velocity.z += direction.z * 0.50
	velocity.y = lerpf(velocity.y,1.5,0.3)
	can_airdash = true
	return direction4
	#get_slide_collision(0) gets the objects that are touching the player
	#wallnormal.get_normal() gets the direction that face the player is touching is facing
	#apply force towards that face (make wallnormal.get_normal() negative)
	#apply small counter-acting force to gravity
	
	#direction4 is a Vector3 containing the direction towards the wall

func gravity3(delta):
	if velocity.y < 5.5:
		velocity += get_gravity() * delta * fall_multiplier
	else:
		velocity += get_gravity() * delta
	# if the player's vertical velocity is low, apply higher gravity
	# makes it so the player's falling speed faster than climbing
	# makes movement feel less floaty
