extends CharacterBody2D
class_name Car

# Car properties
@export var enginePower: float = 1000.0
@export var reverse_coeff: float = 0.5

@export var steer_angle: float = 0.0
@export var steer_strength: float = 5.0
@export var max_steer_angle: float = PI/4

var _force_long: Vector2 = Vector2.ZERO
var _accel: Vector2 = Vector2.ZERO
var _mass: float = 5.0

# Environmental properties
@export var drag_coeff: float = 0.02
@export var friction_coeff: float = 0.5


# Environmental (move to obstacles, etc.)
@export var wall_bounce_factor: float = 0.8

# Car inputs
var _throttle: float = 0.0
var _steer: float = 0.0

var _new_velocity: Vector2 = Vector2.ZERO
var _new_steer_angle: float = 0.0
var _d_steer_angle: float = 0.0
var _angular_velocity: float = 0.0

var _axle_length: float = 20.0
var _front_turn_radius: float = 0.0
var _rear_turn_radius: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	get_input() # get throttle, steer
	
	_new_steer_angle = clampf(
		steer_angle + steer_strength * _steer * delta,
		-max_steer_angle, max_steer_angle)
	
	_d_steer_angle = _new_steer_angle - steer_angle
	
	$frontTireLeft.rotate(_d_steer_angle)
	$frontTireRight.rotate(_d_steer_angle)
	
	if _new_steer_angle != 0.0:
		_front_turn_radius = _axle_length / abs(sin(_new_steer_angle))
	else:
		_front_turn_radius = 0.0
	_rear_turn_radius =  _front_turn_radius * cos(_new_steer_angle)
	
	var force_trac = _throttle * global_transform.x.normalized() * enginePower
	var force_drag = -drag_coeff * velocity * velocity.length()
	var force_friction = -friction_coeff * velocity
	
	_force_long = force_trac + force_drag + force_friction
	_accel = _force_long / _mass
	_new_velocity = (velocity + delta * _accel)
	
	if _front_turn_radius != 0.0:
		_angular_velocity = _new_velocity.length() / _front_turn_radius
	else:
		_angular_velocity = 0.0
	
	if _new_steer_angle >= 0.0:
		rotate(_angular_velocity * delta)
	else:
		rotate(- _angular_velocity * delta)
	velocity = _new_velocity
	steer_angle = _new_steer_angle
	


	




	var collision = move_and_collide(velocity * delta)
	if collision:
		var normal: Vector2 = collision.get_normal()
		bounce(normal)
	


func get_new_steer_angle(delta):
	return clampf(
		steer_angle + steer_strength * _steer * delta,
		-max_steer_angle, max_steer_angle)
		
		
func get_input():
	_throttle = Input.get_axis("ui_down", "ui_up")
	if _throttle == -1:
		_throttle *= reverse_coeff
	_steer = Input.get_axis("ui_left", "ui_right")


func get_force_long() -> Vector2:
	var force_trac = _throttle * global_transform.x.normalized().rotated(_new_steer_angle) * enginePower
	var force_drag = -drag_coeff * velocity * velocity.length()
	var force_friction = -friction_coeff * velocity
	print("force_trac:",force_trac)
	print("force_drag:",force_drag)
	print("force_friction:",force_friction)
	return force_trac + force_drag + force_friction

	
func get_acceleration() -> Vector2:
	return _force_long / _mass
	
	
func get_new_velocity(delta) -> Vector2:
	return (velocity + delta * _accel).rotated(_d_steer_angle)
	
	



func get_front_turn_radius() -> float:
	if _new_steer_angle != 0.0:
		return _axle_length / abs(sin(_new_steer_angle))
	else:
		return 0.0


func get_rear_turn_radius() -> float:
	return _front_turn_radius * cos(steer_angle)

func bounce(normal: Vector2) -> void:
	velocity -= wall_bounce_factor * 2 * normal * velocity.dot(normal)


func update_velocity():
	velocity = _new_velocity.rotated(_d_steer_angle)


func update_steer_angle():
	steer_angle = _new_steer_angle
