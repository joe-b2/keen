extends AnimatedSprite

func _ready():
	get_node("AnimationPlayer").set_speed(rand_range(1.0, 1.2))

func die():
	get_node("AnimationPlayer").set_current_animation("death")