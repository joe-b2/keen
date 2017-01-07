extends Area2D

func _ready():
	pass


func _on_pole_hole_body_enter( body ):
	#print(body.get_name() + " Entering")
	if (body.get_name() == "Player"):
		if body.on_pole == true:
			body.on_pole_hole = false
		else:
			body.on_pole_hole = true

func _on_pole_hole_body_exit( body ):
	#print(body.get_name() + " Exiting")
	if (body.get_name() == "Player"):
		body.on_pole_hole = false
