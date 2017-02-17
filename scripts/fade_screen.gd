extends Sprite

func _ready():
	self.show()
	fade_in()
	pass

func fade_out():
	get_node("AnimationPlayer").play("fade_out")
	
func fade_in():
	get_node("AnimationPlayer").play("fade_in")