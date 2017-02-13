extends Area2D

export var extend_down = 0

func _ready():
	var col = get_node("pole_col").get_polygon()
	col[2].y = 16+(16*extend_down)
	col[3].y = 16+(16*extend_down)
	get_node("pole_col").set_polygon(col)
	self.remove_shape(0)
	get_node("Sprite").set_scale(Vector2(1, 1 + extend_down))
	
	var shape = ConvexPolygonShape2D.new()
	shape.set_points(col)
	self.add_shape(shape)

func _on_pole_body_enter( body ):
	if (body.get_name() == "Player"):
		body.touching_pole = true
		body.at_top = false
		body.at_bot = false
		body.pole_x = self.get_pos().x + 8
		body.pole_top = self.get_pos().y
		body.pole_bot = self.get_pos().y + 16 + (16 * extend_down)


func _on_pole_body_exit( body ):
	if (body.get_name() == "Player"):
		body.touching_pole = false
