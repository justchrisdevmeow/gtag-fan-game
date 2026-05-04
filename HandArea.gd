extends Area3D

var parent = null

func _ready():
	parent = get_node("/root/XROrigin3D")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("climbable"):
		parent.start_climbing(body)

func _on_body_exited(body):
	if body.is_in_group("climbable"):
		parent.stop_climbing()
