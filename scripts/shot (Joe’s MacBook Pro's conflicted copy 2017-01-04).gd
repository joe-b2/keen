extends KinematicBody2D

const SPEED = 200
var dir = Vector2(0, 0)
var velocity = Vector2()

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	velocity = (dir * SPEED) * delta
	self.move(velocity)
	
	
func set_dir( new_dir ):
	dir = new_dir

func _on_Area2D_body_enter( body ):
	var die = true
	if body.has_node("slug_col"):
		if !body.dead:
			body.die()
		else:
			die = false
	if die:
		queue_free()
