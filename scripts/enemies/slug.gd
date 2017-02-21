extends KinematicBody2D

var poop = preload("res://scenes/enemies/poop.tscn")

# Laws of Physics
const GRAVITY = Vector2(0, 400)

const MOVEMENT_SPEED = 30
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_FRICTION = 20
const ACCELERATION = 1

# Enemy variables
var dead = false
var velocity = Vector2()
var facing = "right"
var random_poop = 300
var rp_count = 0
var pooping = false



func _ready():
	set_fixed_process(true)
	randomize()
	random_poop = rand_range(20, 300)

func _fixed_process(delta):
	# Skip if dead
	if !dead:
		# Movement
		var movement = 0
		if facing == "right":
			movement += 1
		else:
			movement -= 1
		
		if pooping:
			movement = 0
		
		movement *= MOVEMENT_SPEED
		
		# Change horizontal velocity
		velocity.x = lerp(velocity.x, movement, ACCELERATION)
		
		# Add Gravity
		velocity += GRAVITY * delta
		
		# apply forces
		velocity = move_and_slide( velocity, FLOOR_NORMAL, SLOPE_FRICTION)
		
		# Poop
		if !pooping:
			if velocity.x * delta < 0:
				rp_count += velocity.x * delta * -1
			else:
				rp_count += velocity.x * delta
	
		if rp_count > random_poop && !pooping:
			pooping = true
			rp_count = 0
			random_poop = rand_range(50, 300)
			get_node("AnimationPlayer").set_current_animation("pooping")
		
func turn():
	if !dead:
		if facing == "right":
			facing = "left"
			self.get_node("AnimatedSprite").set_flip_h(true)
			get_node("Particles2D2").set_pos(Vector2(2, -9.75))
		elif facing == "left":
			facing = "right"
			self.get_node("AnimatedSprite").set_flip_h(false)
			get_node("Particles2D2").set_pos(Vector2(9.25, -9.75))


func _on_left_ledge_detect_body_exit( body ):
	if facing == "left":
		self.turn()


func _on_right_ledge_detect_body_exit( body ):
	if facing == "right":
		self.turn()


func _on_right_wall_detect_body_enter( body ):
	if facing == "right":
		self.turn()


func _on_left_wall_detect_body_enter( body ):
	if facing == "left":
		self.turn()
		
func post_poop():
	var node = poop.instance()
	node.set_pos(Vector2(self.get_pos().x, self.get_pos().y + 15))
	get_parent().add_child(node)
	pooping = false
	get_node("AnimationPlayer").play("walking")
	if rand_range(0, 10) > 5:
			turn()

func die():
	dead = true
	get_node("AnimationPlayer").stop_all()
	if rand_range(0, 10) > 5:
		get_node("AnimationPlayer").play("dead1")
	else:
		get_node("AnimationPlayer").play("dead2")
	get_node("slug_col").set_trigger(true)
	get_node("death_col").queue_free()