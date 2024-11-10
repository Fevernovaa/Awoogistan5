extends CharacterBody3D


var sprint_multiplier := 1.8
var fall_multiplier := 2.8
var JUMP_VELOCITY := 12
var rotation_x: float = 0
var rotation_y: float = 0
var sensitivity: float = 0.1
@onready var camera : Camera3D = $Camera3D
var can_jump := false
var can_airdash := false
@onready var raycast1 : RayCast3D = $RayCast3D
var direction4
var floorcheck : bool


func _physics_process(delta: float) -> void:
	var SPEED = 8
	var input_dir = Input.get_vector("A", "D", "W", "S")
	var direction = (camera.transform.basis.x * input_dir.x + camera.transform.basis.z * input_dir.y)
	direction.y = 0
	direction = direction.normalized()
	floorcheck = raycast1.is_colliding()
	print(floorcheck)
	if Input.is_action_pressed("Sprint"):
		SPEED = SPEED * sprint_multiplier
	if floorcheck:
		velocity.x += (direction.x * SPEED - velocity.x) * 0.2
		velocity.z += (direction.z * SPEED - velocity.z) * 0.2
		can_jump = true
		can_airdash = true
		if Input.is_action_pressed("ui_accept") and can_jump == true:
			jump()
	elif floorcheck and direction == Vector3.ZERO:
		velocity.x += -velocity.x * 0.03
		velocity.z += -velocity.z * 0.03
		can_jump = true
		can_airdash = true
		if Input.is_action_pressed("ui_accept") and can_jump == true:
			jump()
	elif !floorcheck:
		velocity.x += (direction.x * SPEED - velocity.x ) * 0.03
		velocity.z += (direction.z * SPEED - velocity.z ) * 0.03
		
		if velocity.y < 5:
			velocity += get_gravity() * delta * fall_multiplier
		else:
			velocity += get_gravity() * delta
		
		
		if is_on_wall():
			if velocity.length() > 8:
				direction4 = wall_ride(SPEED)
				if Input.is_action_just_pressed("ui_accept"):
					jump_off_wall(direction4)
			else:
				velocity += get_gravity() * fall_multiplier * delta
		else:
			if Input.is_action_pressed("air_dash") and can_airdash == true:
				air_jump(direction,SPEED)
				can_airdash = false
	move_and_slide()
	

func jump():
	can_jump = false
	velocity.y += JUMP_VELOCITY

func air_jump(direction,SPEED):
	velocity.y += JUMP_VELOCITY / 5
	velocity.x += (direction.x * SPEED * 1.2)
	velocity.z += (direction.z * SPEED * 1.2)

func jump_off_wall(direction4):
	velocity.y += JUMP_VELOCITY * 1.3
	velocity.x -= direction4.x * 1.8
	velocity.z -= direction4.z * 1.8

func wall_ride(SPEED):
	var wallnormal := get_slide_collision(0)
	var direction4 =  -wallnormal.get_normal() * SPEED
	velocity.x += (direction4.x - velocity.x) * 0.01
	velocity.z += (direction4.z - velocity.z) * 0.01
	velocity.y = lerpf(velocity.y,3,0.1)
	return direction4
