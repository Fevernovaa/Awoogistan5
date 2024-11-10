extends CSGMesh3D

var freq := 0.75 
var amp := 0.08
var bob_5 := 0.0
var pos = Vector3()
#the bow also has left and right movement, not up and down
#tbh i could probably access the pos variable from the camera script
@onready var char = $"..".get_parent().get_parent() #reference to the character

func _physics_process(delta: float) -> void:
	bob_5 += char.velocity.length() * delta * float(char.is_on_floor())
	transform.origin.x = headbob(bob_5).x #only the x component of Vector3
	#reminder, pos is a Vector3 and we only set the x value, so the other values are 0
	
	if Input.is_action_just_pressed("reload"):
		#placeholder reload
		$"../AnimationPlayer".play("reload")
		# PSA they are not the same
		# "reload" is an input and "reload" is the animation
		# unfortunate naming

func headbob(time):
	pos.x = cos(time * freq/2) * amp/2
	return pos
