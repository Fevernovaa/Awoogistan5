extends Camera3D

var rotation_x: float = 0
var rotation_y: float = 0
var sensitivity: float = 0.1
var last_position := Vector3.ZERO
@onready var camera : Camera3D = $Camera3D
var freq := 1.5
var amp := 0.09
var bob_5 := 0.0
var pos = Vector3()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_delta = event.relative
		rotation_y -= mouse_delta.x * sensitivity * 0.05
		rotation_x -= mouse_delta.y * sensitivity * 0.05

func _physics_process(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y,rotation_y,0.95)
	rotation_x = clamp(rotation_x,deg_to_rad(-80),deg_to_rad(80))
	rotation.x = lerp_angle(rotation.x,rotation_x,0.95)
	var camspeed = (global_transform.origin - last_position) / delta
	last_position = global_transform.origin
	var local_speed = global_transform.basis.inverse() * camspeed
	rotation.z = -local_speed.x / 100
	rotation.z = lerp_angle(rotation.z,0,0.5)
	$_bow_.rotation.x = -local_speed.y / 75
	$_bow_.rotation.x = lerp_angle($_bow_.rotation.x,0,0.02)
	
	bob_5 += $"..".velocity.length() * delta * float($"..".is_on_floor())
	transform.origin = headbob(bob_5)
	

func headbob(time):
	pos.y = sin(time * freq) * amp
	pos.x = cos(time * freq/2) * amp/2
	return pos
