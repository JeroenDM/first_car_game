extends KinematicBody2D

var wheel_base_front = 20
var wheel_base_rear = 10
var steering_angle = 20
var engine_power = 200
var engine_backwards_power = 50
var friction = -0.5
var drag = -0.0001
var slip_speed = 100
var traction_fast = 0.1
var traction_slow = 0.7

var acceleration = Vector2.ZERO
var velocity = Vector2.ZERO
var steer_direction

func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	velocity = move_and_slide(velocity)

func apply_friction():
	print(velocity.length())
	if velocity.length() < 5 && !Input.is_action_pressed("brake") && !Input.is_action_pressed("throttle"):
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	acceleration += drag_force + friction_force

func get_input():
	# calculate steering angle
	var turn = 0
	if Input.is_action_pressed("steer_right"):
		turn += 1
	if Input.is_action_pressed("steer_left"):
		turn -= 1
	steer_direction = turn * deg2rad(steering_angle)
	
	# calculate forward speed
	if Input.is_action_pressed("throttle"):
		acceleration = transform.x * engine_power
	elif Input.is_action_pressed("brake"):
		acceleration = -transform.x * engine_backwards_power

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base_rear
	var front_wheel = position + transform.x * wheel_base_front
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	
	# figure out if we want to move forward or backwards
	var d = new_heading.dot(velocity.normalized())
	if d >= 0:
		velocity = velocity.linear_interpolate(new_heading * velocity.length(), traction)
	elif d < 0:
		velocity = -new_heading * velocity.length()
	rotation = new_heading.angle()
