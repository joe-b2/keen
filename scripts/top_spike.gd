extends Sprite

export var speed = 1.5
var timer = 0

func _ready():
	set_fixed_process(true)
	if speed < 0.5:
		speed = 0.5

func _fixed_process(delta):
	timer += delta
	if timer > speed:
		timer = 0
		get_node("AnimationPlayer").play("poke")