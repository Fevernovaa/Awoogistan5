extends Camera3D

var rotation_x: float = 0 #set later
var rotation_y: float = 0 #set later
var sensitivity: float = 0.1 
var last_position := Vector3.ZERO #explained later
@onready var camera : Camera3D = $Camera3D #reference to camera
var freq := 1.5 #headbobing frequency
var amp := 0.09 #how hard the headbobing is (distance up and down)
var bob_5 := 0.0 #explained later
var pos = Vector3() #set later

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#removes the cursor and makes it stuck to the window
	#not sure how to explain, try commenting the line and testing it yourself
	pass

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_delta = event.relative
		rotation_y -= mouse_delta.x * sensitivity * 0.05
		rotation_x -= mouse_delta.y * sensitivity * 0.05
	#gets the mouse movements, multiply them by the sensitivity and then by 0.05
	#without the 0.05 the sensitivity is comiclly high
	
	#rotation_y and rotation_x are gonna carry the mouse movements information
	#we apply them later

func _physics_process(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y,rotation_y,0.95)
	rotation_x = clamp(rotation_x,deg_to_rad(-80),deg_to_rad(80))
	rotation.x = lerp_angle(rotation.x,rotation_x,0.95)
	#apply rotation_y and rotation_x, and clamp rotation.x so i can't look 360 degrees up and down
	#lerp is used to make it smoother, smoothness is controlled by the last integer in the function 
	# rn its 0.95
	var camspeed = (global_transform.origin - last_position) / delta
	last_position = global_transform.origin
	var local_speed = global_transform.basis.inverse() * camspeed
	#calculate the camera's speed, used for headbob, camera lean and weapon up/down movement
	#the faster the player the faster the headbob, higher camera lean, and more up/down movement

	rotation.z = -local_speed.x / 100
	rotation.z = lerp_angle(rotation.z,0,0.5)
	#camera lean, lerp_angle resets the camera's lean back to 0
	#bugs out if you use lerp or lerpf instead of lerp_angle
	#alsoways use lerp_angle for angles
	
	$_bow_.rotation.x = -local_speed.y / 75
	$_bow_.rotation.x = lerp_angle($_bow_.rotation.x,0,0.02)
	#weapon's up and down movement
	
	bob_5 += $"..".velocity.length() * delta * float($"..".is_on_floor())
	#$"..".velocity.length() gets the player's speed
	#float($"..".is_on_floor()) checks if the player is on the floor
	#if is_on_floor is false, it returns 0, which is multiplied by the whole function
	#so basiclly float(bool) will return 1 or 0
	
	
	
	transform.origin = headbob(bob_5) 
	#pos is returned, which is altered by the sin and cos waves
	#sets the camera's location based on pos
	

func headbob(time):
	pos.y = sin(time * freq) * amp
	#just look at a sin wave and you'd see why its used
	pos.x = cos(time * freq/2) * amp/2
	#left and right "headbob"
	return pos
