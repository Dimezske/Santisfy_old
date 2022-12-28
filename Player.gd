extends KinematicBody

export var speed := 17.0
export var jump_strength := 20.0
export var gravity := 50.0
export var water_force := 15.0


var sink_speed := 2.5
var floating
var sinking

var _velocity := Vector3.ZERO
var _snap_vector := Vector3.DOWN
var move_vector := Vector3()

onready var _camera: Camera = $Camera
onready var _model: Spatial = $Model/CSGSphere
onready var _water_plane = get_node("/root/Water").get_node("MeshInstance")
onready var _water_space = get_node("/root/Water").get_node("Area")

enum States{
	IN_WATER,
	WALKING,
}
var moving
onready var tint = $Camera/ColorRect
func _ready():
	tint.hide()
func _physics_process(delta: float) -> void:
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	move_direction = move_direction.rotated(Vector3.UP, _camera.rotation.y).normalized()
	
	if not Global.in_water:
		_velocity.x = move_direction.x * speed
		_velocity.z = move_direction.z * speed
		jump_strength = 20.0
		_velocity.y -= gravity * delta
	
	var just_landed := is_on_floor() and _snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	if is_jumping:
		_velocity.y = jump_strength
		_snap_vector = Vector3.ZERO
	elif just_landed:
		_snap_vector = Vector3.DOWN
	_velocity = move_and_slide_with_snap(_velocity, _snap_vector, Vector3.UP, true)
	
	if Global.in_water:
		floating = self.global_transform.origin.y >= _water_plane.global_transform.origin.y
		#create a new move vector that's just the *unrotated* movement direction from keyboard
		move_vector = Vector3(Input.get_action_strength("right") - Input.get_action_strength("left"), 0, Input.get_action_strength("back") - Input.get_action_strength("forward"))
		moving = move_vector.length() > 0.2 #or some small number...
		if floating:
			_velocity.y += gravity * delta
			move_direction = move_direction.rotated(Vector3.FORWARD, _camera.rotation.y)
#			_velocity += move_direction * delta #because move_direction is already "rotated" for the camera
		#we're under the surface, so move in the direction of the camera
		elif moving:
			move_vector = move_vector.normalized()
			_velocity += _camera.global_transform.basis.x * move_vector.x * delta
			_velocity += _camera.global_transform.basis.y * move_vector.y * delta
			_velocity += _camera.global_transform.basis.z * move_vector.z * delta
		#otherwise, just sink
		else:
			_velocity += Vector3(0, -sink_speed, 0)
#	if Global.in_water:
#		jump_strength = 0
#		if Input.get_action_strength("forward"):
#			_velocity += _camera.global_transform.basis.z * move_direction.z * delta
#			_velocity += _camera.global_transform.basis.y * move_direction.y * delta
#			translate(global_transform.basis.y * speed * delta)
#			if _camera.global_transform.origin.z < _water_plane.global_transform.origin.z:
#				floating = true
#				if floating:
#					_velocity.y += gravity * delta
#					if floating and Input.is_action_just_pressed("jump"):
#						sinking = false
#					if floating and not Input.is_action_just_pressed("jump"):
#						sinking = true
#				if sinking:
#					if _camera.global_transform.origin.y < _water_space.global_transform.origin.y:
#						_velocity.y -= gravity / 5 * delta + 2
	
#	if Global.in_water:
#		floating = true
#		if Input.get_action_strength("forward"):
#			_velocity += _camera.global_transform.basis.z * move_direction.z * delta
#		if Input.is_action_just_pressed("jump"):
#
#			if floating:
#				_velocity.y += gravity * delta
#			else:
#				if _camera.global_transform.origin.y < _water_space.global_transform.origin.y:
#					floating = false
#					_velocity.y -= gravity * delta
#
