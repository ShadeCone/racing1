extends CharacterBody2D
class_name Car

# Car properties
@export var enginePower: float = 1000.0
@export var reverse_coeff: float = 0.5

@export var steer_angle: float = 0.0
@export var steer_strength: float = 2.0
@export var max_steer_angle: float = 0.35 * PI/4

var _force_long: Vector2 = Vector2.ZERO
var _accel: Vector2 = Vector2.ZERO
var _mass: float = 5.0

# Environmental properties
@export var drag_coeff: float = 0.03
@export var friction_coeff: float = 30 * drag_coeff


# Environmental (move to obstacles, etc.)
@export var wall_bounce_factor: float = 0.5

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

var force_lat: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
		


func _draw():
	var car_heading = 50 * Vector2.RIGHT
	var loc_v = global_transform.basis_xform_inv(velocity)
	draw_line(Vector2.ZERO, loc_v, Color.BLUE, 2.0)
	var tire_dir = 30 * Vector2.RIGHT.rotated(steer_angle)
	var tire_pos_l = $frontTireLeft.position
	var tire_pos_r = $frontTireRight.position
	draw_line(tire_pos_l, tire_pos_l + tire_dir, Color.RED, 2.0)
	draw_line(tire_pos_r, tire_pos_r + tire_dir, Color.RED, 2.0)
	draw_line(Vector2.ZERO, car_heading, Color.YELLOW, 2.0)
	var lat_f = global_transform.basis_xform_inv(force_lat)
	draw_line(tire_pos_r, tire_pos_r + 0.4 * lat_f, Color.PURPLE, 2.0)
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
		_front_turn_radius = -1.0
	_rear_turn_radius = _front_turn_radius * cos(_new_steer_angle)
	
	var force_trac = _throttle * global_transform.x.normalized() * enginePower
	var force_drag = -drag_coeff * velocity * velocity.length()
	var force_friction = -friction_coeff * velocity
	
	#force_lat = -200 * velocity.dot(global_transform.x.rotated(_new_steer_angle - PI/2).normalized()) * global_transform.x.rotated(_new_steer_angle - PI/2).normalized()
	_force_long = force_trac + force_drag + force_friction #+ force_lat
	_accel = _force_long / _mass
	_new_velocity = (velocity + delta * _accel)
	
	if _front_turn_radius != -1.0:
		_angular_velocity = _new_velocity.length() / _front_turn_radius
		if _new_steer_angle < 0.0:
			_angular_velocity *= -1
		if velocity.dot(global_transform.x) < 0:
			_angular_velocity *= -1
	else:
		_angular_velocity = 0.0
	
	rotate(_angular_velocity * delta)

	velocity = _new_velocity.rotated(_angular_velocity * delta)
	steer_angle = _new_steer_angle
	


	




	var collision = move_and_collide(velocity * delta)
	if collision:
		var normal: Vector2 = collision.get_normal()
		bounce(normal)
	queue_redraw()



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
	velocity *= -wall_bounce_factor
	#velocity -= wall_bounce_factor * 2 * normal * velocity.dot(normal)


func update_velocity():
	velocity = _new_velocity.rotated(_d_steer_angle)


func update_steer_angle():
	steer_angle = _new_steer_angle
