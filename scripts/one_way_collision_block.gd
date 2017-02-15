extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_Player_Detect_body_enter( body ):
	if (body.get_name() == "Player"):
		body.get_node("CollisionShape2D2").set_trigger(true)


func _on_Player_Detect_body_exit( body ):
	if (body.get_name() == "Player"):
		body.get_node("CollisionShape2D2").set_trigger(false)
