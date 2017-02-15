extends Sprite

func _ready():
	pass

func fade_out():
	get_node("AnimationPlayer").play("fade_out")
	
func fade_in():
	get_node("AnimationPlayer").play("fade_in")