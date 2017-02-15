extends KinematicBody2D

var shot = preload("res://scenes/shot.tscn")
export var init_face_right = true

# Laws of Physics
const GRAVITY = Vector2(0, 400)

# Movement variables
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_FRICTION = 20
const MOVEMENT_SPEED = 100
const ACCELERATION = 0.25
const JUMP_FORCE = 300
const LOW_POGO_FORCE = 200
const HIGH_POGO_FORCE = 350
const POLE_CLIMB_SPEED = 60

# Player Variables
var velocity = Vector2()
var on_pogo = false
var facing = "right"
var on_ledge = false
var climbing = false
var shooting = false

# Jumping
var wants_to_jump = false
var wants_to_jump_timer = 0
var can_jump = false
var allow_jump = false
var jump_timer = 0
var jump_off_pole = false
var force_jump_anim = false

#Moving Platform Variables
var mp_node
var on_mp = false
var mplastx

# Poles
var touching_pole = false
var on_pole = false
var pole_x = 0
var pole_top = 0
var pole_bot = 0
var at_top_of_pole = false
var at_top = false
var at_bot = false

# Shooting
var shot_type = "shoot_standing"

# Camera Variables
var cam_limit = Vector2(0, 0)
var cam_offset = Vector2(1000000,1000000)

# Doors
var on_door = false
var door_node
var entering_door = false

func _ready():
	get_node("Lighting").show()
	set_fixed_process(true)
	if !init_face_right:
		facing = "left"
		get_node("AnimatedSprite").set_flip_h(true)

func _fixed_process(delta):
	if !climbing && !entering_door:
		# Movement
		var movement = 0
		
		if (Input.is_action_pressed("ui_left") && !shooting):
			get_node("AnimatedSprite").set_flip_h(true)
			movement -= 1
			if on_pole && !Input.is_action_pressed("ui_down") && !Input.is_action_pressed("ui_up"):
				on_pole = false
				force_jump_anim = true
			if !facing == "left" && on_ledge:
					on_ledge = false
					get_node("AnimationPlayer").set_current_animation("falling_down")
			facing = "left"
		
		if (Input.is_action_pressed("ui_right") && !shooting):
			get_node("AnimatedSprite").set_flip_h(false)
			movement +=1
			if on_pole && !Input.is_action_pressed("ui_down") && !Input.is_action_pressed("ui_up"):
				on_pole = false
				force_jump_anim = true
			if !facing == "right" && on_ledge:
					on_ledge = false
					get_node("AnimationPlayer").set_current_animation("falling_down")
			facing = "right"
		
		movement *= MOVEMENT_SPEED
		
		# Change horizontal velocity
		velocity.x = lerp(velocity.x, movement, ACCELERATION)
		
		# Moving Platform
	
		if (on_mp):
			# Horizontal Moving Platforms
			var mpxadj = mp_node.get_pos().x - mplastx
			mplastx = mp_node.get_pos().x
			
			if !on_pogo:
				self.set_pos(Vector2(self.get_pos().x + mpxadj, mp_node.get_pos().y - 11))
				
		
		# Poles
		
		if (on_pole && touching_pole):
			var p_movement = 0
			jump_off_pole = true
			
			if (self.get_pos().y < pole_top+18):
				at_top = true
			
			if (self.get_pos().y > pole_bot-5 && !Input.is_action_pressed("ui_up") && !Input.is_action_pressed("ui_down")):
				on_pole = false
				at_bot = true
			
			if (Input.is_action_pressed("ui_up") && !at_top):
				p_movement -= 1
		
			if (Input.is_action_pressed("ui_down") && !at_bot):
				p_movement += 1
				at_top = false
			
			p_movement *= POLE_CLIMB_SPEED
			velocity.y = lerp(velocity.y, p_movement, ACCELERATION)
		
		# Gravity
		
		if !on_pole && !on_mp:
			# Add Gravity
			velocity += GRAVITY * delta
		
		# More Poles
		if !touching_pole:
			on_pole = false
			
		if (touching_pole && !on_pogo):
			if (Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down")):
				if self.get_pos().y < pole_top && Input.is_action_pressed("ui_up"):
					on_pole = false
				elif self.get_pos().y > pole_bot - 1 && Input.is_action_pressed("ui_down"):
					on_pole = false
				else:
					velocity.x = 0
					self.set_pos(Vector2(pole_x, self.get_pos().y))
					on_pole = true
			
		# At top of pole
		if on_pole && at_top:
			at_top_of_pole = true
		else:
			at_top_of_pole = false
		
		# apply forces
		velocity = move_and_slide( velocity, FLOOR_NORMAL, SLOPE_FRICTION)
		
		# Can jump?
		var could_jump = can_jump
		can_jump = is_move_and_slide_on_floor()
		 
		if (on_mp || on_pole) && !shooting:
			can_jump = true
			
		# Jump timer
		if could_jump && !can_jump:
			jump_timer = 0
		jump_timer += delta
		if !can_jump && jump_timer < 0.2:
			allow_jump = true
		else:
			allow_jump = false
		
		# Wants to jump timer
		wants_to_jump_timer += delta
		if wants_to_jump_timer > 0.2 && wants_to_jump:
			wants_to_jump = false
		
		# Jump
		if Input.is_action_just_pressed("jump"):
			wants_to_jump = true
			wants_to_jump_timer = 0
		if !on_pogo && !shooting && (allow_jump || can_jump) && wants_to_jump:
			wants_to_jump = false
			if (on_pole && !Input.is_action_pressed("ui_up") && !Input.is_action_pressed("ui_down")):
				velocity.y -= JUMP_FORCE/2
	
			if (!on_pole):
				if jump_off_pole && !can_jump:
					velocity.y -= JUMP_FORCE/2
					jump_off_pole = false
					force_jump_anim = true
				else:
					velocity.y -= JUMP_FORCE
					jump_off_pole = false
				
			
			on_mp = false
			on_pole = false
			can_jump = false
		
		if Input.is_action_just_pressed("pogo") && !shooting:
			if on_pogo:
				on_pogo = false 
				wants_to_jump = false
				get_node("CollisionShape2D2").set_trigger(false)
			else:
				if !on_ledge:
					on_pogo = true
					get_node("CollisionShape2D2").set_trigger(true)
		
		if on_pogo:
			if !get_node("CollisionShape2D2").is_trigger():
				get_node("CollisionShape2D2").set_trigger(true)
			if can_jump && Input.is_action_pressed("jump"):
				if !on_mp:
					velocity.y -= HIGH_POGO_FORCE
				else:
					velocity.y -= HIGH_POGO_FORCE / 10
			elif can_jump:
				if !on_mp:
					velocity.y -= LOW_POGO_FORCE
				else:
					velocity.y -= LOW_POGO_FORCE / 15
		# Doors
		if on_door && Input.is_action_pressed("ui_up") && can_jump:
			self.set_pos(Vector2(door_node.get_pos().x + 18, self.get_pos().y))
			get_node("AnimationPlayer").set_current_animation("enter_door")
			entering_door = true
			get_node("fade_screen").fade_out()
		
		# Animations
		if on_ledge:
			get_node("AnimationPlayer").set_current_animation("hanging")
		if on_pole && !force_jump_anim:
			if (Input.is_action_pressed("ui_up") && !Input.is_action_pressed("ui_down") && get_node("AnimationPlayer").get_current_animation() != "up_pole") || at_top || at_bot:
				get_node("AnimationPlayer").set_current_animation("up_pole")
			elif Input.is_action_pressed("ui_down") && !Input.is_action_pressed("ui_up") && get_node("AnimationPlayer").get_current_animation() != "down_pole":
				get_node("AnimationPlayer").play("down_pole")
			elif (!Input.is_action_pressed("ui_up") && !Input.is_action_pressed("ui_down")) || (Input.is_action_pressed("ui_up") && Input.is_action_pressed("ui_down")):
				get_node("AnimationPlayer").play("pole_idle")
		if can_jump && !on_pole && !on_pogo && !on_ledge && !shooting && !entering_door:
			if Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right"):
				if get_node("AnimationPlayer").get_current_animation() != "run":
					get_node("AnimationPlayer").set_current_animation("run")
			else: 
				if get_node("AnimationPlayer").get_current_animation() != "idle":
					get_node("AnimationPlayer").set_current_animation("idle")
		if !entering_door && !shooting && !on_pogo && !can_jump && (velocity.y < -80 || force_jump_anim):
			force_jump_anim = false
			if get_node("AnimationPlayer").get_current_animation() != "jumping_up":
					get_node("AnimationPlayer").set_current_animation("jumping_up")
		if !entering_door && !shooting && !on_pogo && !can_jump && (velocity.y >= 80 || force_jump_anim):
			force_jump_anim = false
			if get_node("AnimationPlayer").get_current_animation() != "falling_down":
					get_node("AnimationPlayer").set_current_animation("falling_down")
		if on_pogo:
			get_node("AnimationPlayer").set_current_animation("pogo_up")
			if velocity.y >= 50:
				get_node("AnimationPlayer").set_current_animation("pogo_down")
		if on_ledge && facing == "right" && Input.is_action_pressed("ui_right") && velocity.y == 0:
			climbing = true
			get_node("AnimationPlayer").set_current_animation("climbing")
		if on_ledge && facing == "left" && Input.is_action_pressed("ui_left") && velocity.y == 0:
			climbing = true
			get_node("AnimationPlayer").set_current_animation("climbing")
		if !entering_door && !shooting && can_jump && !on_pole && !on_pogo && !on_ledge && Input.is_action_pressed("fire_shot") && Input.is_action_pressed("ui_up"):
			shot_type = "shoot_up_standing"
			shooting = true
			get_node("AnimationPlayer").set_current_animation(shot_type)
		if !entering_door && !shooting && can_jump && !on_pole && !on_pogo && !on_ledge && Input.is_action_pressed("fire_shot"):
			shot_type = "shoot_standing"
			shooting = true
			get_node("AnimationPlayer").set_current_animation(shot_type)
		if !entering_door && !shooting && !on_pogo && !can_jump && Input.is_action_pressed("fire_shot"):
			shot_type = "shoot_falling"
			shooting = true
			get_node("AnimationPlayer").set_current_animation(shot_type)

		if !entering_door && shooting && shot_type == "shoot_falling" && can_jump:
			get_node("AnimatedSprite").set_frame(25)


func post_climb():
	get_node("AnimatedSprite").set_frame(0)
	get_node("AnimationPlayer").play("idle")
	if facing == "right":
		self.set_pos(Vector2(self.get_pos().x + 10, self.get_pos().y - 31))
	else:
		self.set_pos(Vector2(self.get_pos().x - 10, self.get_pos().y - 31))
	on_ledge = false
	climbing = false

func fire_shot():
	var world = get_parent().get_node("Lit Objects")
	var node = shot.instance()
	if shot_type == "shoot_standing":
		if facing == "right":
			node.set_pos(Vector2(self.get_pos().x + 15, self.get_pos().y))
			node.set_dir(Vector2(1, 0))
		if facing == "left":
			node.set_pos(Vector2(self.get_pos().x - 15, self.get_pos().y))
			node.set_dir(Vector2(-1, 0))
	if shot_type == "shoot_falling":
		if facing == "right":
			node.set_pos(Vector2(self.get_pos().x + 15, self.get_pos().y - 3))
			node.set_dir(Vector2(1, 0))
		if facing == "left":
			node.set_pos(Vector2(self.get_pos().x - 15, self.get_pos().y - 3))
			node.set_dir(Vector2(-1, 0))
	world.add_child(node)

func post_shot():
	shooting = false 
	get_node("AnimationPlayer").play("idle")
	pass

func enter_door():
	#get_node("Camera2D").set_enable_follow_smoothing( false )
	set_camera_limits(door_node.new_scene_top_left.x, door_node.new_scene_top_left.y, door_node.new_scene_bot_right.x, door_node.new_scene_bot_right.y)
	self.set_pos(door_node.other_door_location)
	get_node("AnimationPlayer").play("idle")
	entering_door = false
	get_node("fade_screen").fade_in()
	#get_node("Camera2D").set_enable_follow_smoothing( true )

func set_camera_limits( left, top, right, bottom ):
	get_node("Camera2D").set_limit(MARGIN_TOP, top)
	get_node("Camera2D").set_limit(MARGIN_LEFT, left)    
	get_node("Camera2D").set_limit(MARGIN_RIGHT, right)
	get_node("Camera2D").set_limit(MARGIN_BOTTOM, bottom)

func _on_ledge_det_body_enter( body ):
	if body.get_name() == "Main TileMap":
		on_ledge = true


func _on_ledge_det_body_exit( body ):
	if body.get_name() == "Main TileMap":
		on_ledge = false

