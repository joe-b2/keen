extends StaticBody2D

func _ready():
	pass


func _on_pole_hole_body_enter( body ):
	#print(body.get_name() + " Entering")
	if (body.get_name() == "Player"):
		if body.on_pole == true:
			pass
		else:
			pass

func _on_pole_hole_body_exit( body ):
	#print(body.get_name() + " Exiting")
	if (body.get_name() == "Player"):
		pass
