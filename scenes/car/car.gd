extends CharacterBody2D
class_name Car

# Car properties
@export var max_speed: float = 200.0
@export var max_reverse_speed: float = 50.0
@export var reverse_coeff: float = 0.5

@export var acceleration: float = 110.0

@export var steer_ratio: float = 0.0
@export var steer_factor: float = 2.0
@export var w2w_half_length: float = 17.0 # front to rear wheels distance

# Road properties (move to track properties later)
@export var friction_coeff: float = 0.4

# Environmental (move to obstacles, etc.)
@export var wall_bounce_factor: float = 0.4

# Car internal values
var _throttle: float = 0.0
var _steer: float = 0.0
var _speed: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	get_input()
	update_speed(delta)
	update_direction(delta)
	velocity = transform.x * _speed
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		bounce()
		velocity = velocity.slide(collision.get_normal())


func get_input():
	var _fwd = Input.get_action_strength("ui_up")
	var _bwd = Input.get_action_strength("ui_down")
	if (_bwd):
		_throttle = reverse_coeff * (_fwd - _bwd)
	else:
		_throttle = _fwd
	_steer = Input.get_axis("ui_left", "ui_right")


func update_speed(delta: float) -> void:
	_speed += (_throttle * acceleration - _speed * friction_coeff) * delta
	_speed = clampf(_speed, -max_reverse_speed, max_speed)
	velocity = transform.x * _speed


func update_direction(delta: float) -> void:
	var steer_angle = steer_factor * _steer * delta
	if _speed < 0.0:
		steer_angle *= -1
	rotate(steer_angle)





func bounce() -> void:
	_speed = - wall_bounce_factor * _speed
