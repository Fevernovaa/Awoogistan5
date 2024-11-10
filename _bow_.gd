extends CSGMesh3D

var freq := 0.75
var amp := 0.08
var bob_5 := 0.0
var pos = Vector3()
@onready var char = $"..".get_parent().get_parent()

func _physics_process(delta: float) -> void:
	bob_5 += char.velocity.length() * delta * float(char.is_on_floor())
	transform.origin.x = headbob(bob_5).x
	
	if Input.is_action_just_pressed("reload"):
		$"../AnimationPlayer".play("reload")

func headbob(time):
	pos.x = cos(time * freq/2) * amp/2
	return pos
