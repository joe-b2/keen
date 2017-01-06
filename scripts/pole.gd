extends Area2D

export var extend_down = 0

func _ready():
	get_node("pole_col").set_shape(get_node("pole_col").get_shape().set_extents(Vector2(8, 24 + (16 * extend_down))))
	get_node("pole_col").set_pos(Vector2(8, -16 + (8 * extend_down)))
	get_node("Sprite").set_scale(Vector2(1, 1 + extend_down))


func _on_pole_body_enter( body ):
	#print(body.get_name() + " Entering")
	if (body.get_name() == "Player"):
		body.touching_pole = true
		body.pole_x = self.get_pos().x + 8
		body.pole_top = self.get_pos().y
		body.pole_bot = self.get_pos().y + 16 + (16 * extend_down)


func _on_pole_body_exit( body ):
	#print(body.get_name() + " Exiting")
	if (body.get_name() == "Player"):
		body.touching_pole = false
