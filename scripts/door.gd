extends Sprite

export var other_door_location = Vector2(0, 0)
export var new_scene_top_left = Vector2(0, 0)
export var new_scene_bot_right = Vector2(0, 0)
export var player_init_face_right = true
var width = 0

func _ready():
	width = self.get_texture().get_width()
	pass
