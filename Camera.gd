extends Camera

export var overlay_path: NodePath
export var collider_path: NodePath
var texture: ColorRect
var camera_collider: StaticBody

const mouse_sensitivity = 0.01
var zoom = 1
var camera = self

func _ready():
	texture = get_node(overlay_path)
	camera_collider = get_node(collider_path)
	
func _input(event):
	if event is InputEventMouseMotion and event.button_mask & 2:
		var rot_x = event.relative.x * mouse_sensitivity
		var rot_y = event.relative.y * mouse_sensitivity
		
		transform.origin = transform.origin.rotated(Vector3(0,1,0), -rot_x)
		rotate(Vector3(0,1,0), -rot_x)
		
		var v = transform.basis.x
		transform.origin = transform.origin.rotated(v, -rot_y)
		rotate(v, -rot_y) # then rotate in X
		
	if Input.is_action_just_released("zoom_in"):
		transform.origin.normalized() * zoom
		if camera.fov >= 40:
			camera.fov -= 5
			print("Zooming In")
	
	if Input.is_action_just_released("zoom_out"):
		transform.origin.normalized() * zoom
		if camera.fov <= 120:
			camera.fov += 5
			print("Zooming Out")
