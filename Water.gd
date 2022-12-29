extends Spatial

export onready var tint = get_node("../../KinematicBody/Camera/ColorRect")

func _on_Area_body_entered(body):
	print(body)
	if body.is_in_group("Player"):
		tint.show()
#		print("player entered")
		Global.in_water = true
		if Global.in_water:
			print("water")
			
func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		tint.hide()
#		print("player exited")
		Global.in_water = false
