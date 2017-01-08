extends StaticBody2D

var player_on = false
var player = null

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	if player_on:
		if player.on_pole && !self.get_node("CollisionShape2D").is_trigger():
			self.get_node("CollisionShape2D").set_trigger(true)
		if player.at_top_of_pole && Input.is_action_pressed("ui_up"):
			self.get_node("CollisionShape2D").set_trigger(false)

func _on_player_detect_body_enter( body ):
	if (body.get_name() == "Player"):
		player = body
		player_on = true
		if body.on_pole == true:
			self.get_node("CollisionShape2D").set_trigger(true)
		else:
			pass


func _on_player_detect_body_exit( body ):
	if (body.get_name() == "Player"):
		player_on = false
		self.get_node("CollisionShape2D").set_trigger(false)
