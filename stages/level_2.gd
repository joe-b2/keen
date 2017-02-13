extends Node

func _ready():
	# Set initial camera limits
	get_node("Player").set_camera_limits(0,0,1600,480)
	pass
