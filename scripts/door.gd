extends Sprite

export var other_door_location = Vector2(0, 0)
export var new_scene_top_left = Vector2(0, 0)
export var new_scene_bot_right = Vector2(0, 0)
export var player_init_face_right = true

func _ready():
	pass

func _on_Area2D_body_enter( body ):
	if (body.get_name() == "Player"):
		body.door_node = self
		body.on_door = true


func _on_Area2D_body_exit( body ):
	if (body.get_name() == "Player"):
		body.on_door = false
