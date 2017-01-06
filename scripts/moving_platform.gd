extends KinematicBody2D
export var Direction = Vector2(0, 1)
export var Travel_Dist = 0
export var Speed = 100

var orig_pos = Vector2()
var movement = Vector2()
var status = 0

func _ready():
	set_fixed_process(true)
	orig_pos = self.get_pos()
	movement = Direction
	
func _fixed_process(delta):
	# When platform makes it to end of run
	if (get_len(orig_pos, self.get_pos()) > Travel_Dist):
		movement = movement * -1
		status = 1
	
	# When platform makes it back home
	if (get_len(orig_pos, self.get_pos()) < 10 && status == 1):
		movement = movement * -1
		status = 0
	
	self.set_pos(self.get_pos() + ((movement * Speed) * delta))
	
	
func get_len(from_pos, to_pos):
	return sqrt(((from_pos.x - to_pos.x)*(from_pos.x - to_pos.x)) + ((from_pos.y - to_pos.y)*(from_pos.y - to_pos.y)))


func _on_Area2D_body_enter( body ):
	if (body.get_name() == "Player"):
		if body.velocity.y > -50 && !get_node("CollisionShape2D").is_trigger():
			body.on_mp = true
			body.mplastx = self.get_pos().x
			body.mp_node = self
	


func _on_Area2D_body_exit( body ):
	if (body.get_name() == "Player"):
		body.on_mp = false


func _on_player_near_body_enter( body ):
	if (body.get_name() == "Player"):
		get_node("CollisionShape2D").set_trigger(false)


func _on_player_near_body_exit( body ):
	if (body.get_name() == "Player"):
		get_node("CollisionShape2D").set_trigger(true)
