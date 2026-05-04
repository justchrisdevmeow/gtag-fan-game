extends XROrigin3D

var left_controller = null
var right_controller = null
var body = null
var left_vel = Vector3.ZERO
var right_vel = Vector3.ZERO
var last_left = Vector3.ZERO
var last_right = Vector3.ZERO
var slide_velocity = Vector3.ZERO
var grounded = false
var climbing = false
var climb_target = null
var jump_cooldown = 0

func _ready():
	left_controller = $LeftHandController
	right_controller = $RightHandController
	body = $MonkeyBody
	last_left = left_controller.global_position
	last_right = right_controller.global_position

func start_climbing(target):
	climbing = true
	climb_target = target
	slide_velocity = Vector3.ZERO
	body.linear_velocity = Vector3.ZERO

func stop_climbing():
	climbing = false
	climb_target = null

func _physics_process(delta):
	var new_left = left_controller.global_position
	var new_right = right_controller.global_position
	left_vel = (new_left - last_left) / delta
	right_vel = (new_right - last_right) / delta
	last_left = new_left
	last_right = new_right
	
	# Ground check (add a RayCast3D named GroundRay under MonkeyBody)
	if body.has_node("GroundRay"):
		grounded = $MonkeyBody/GroundRay.is_colliding()
	else:
		grounded = abs(body.linear_velocity.y) < 0.2 and not climbing
	
	if jump_cooldown > 0:
		jump_cooldown -= delta
	
	if climbing and climb_target:
		var hand_vel = (left_vel + right_vel).y
		body.translate(Vector3(0, hand_vel * delta * 4, 0))
		climb_target.translate(Vector3(0, -hand_vel * delta * 4, 0))
	elif grounded:
		var swing = (left_vel + right_vel) * 0.5
		swing.y = 0
		slide_velocity += swing * 2
		slide_velocity *= 0.95
		body.linear_velocity = slide_velocity
		
		if left_vel.y < -3 and right_vel.y < -3 and jump_cooldown <= 0:
			body.apply_central_impulse(Vector3(0, 7, 0))
			jump_cooldown = 0.5
	else:
		var air_swing = (left_vel + right_vel) * 0.5
		air_swing.y = 0
		body.linear_velocity += air_swing * delta * 1.5
		var vel = body.linear_velocity
		vel.x = clamp(vel.x, -8, 8)
		vel.z = clamp(vel.z, -8, 8)
		body.linear_velocity = vel
