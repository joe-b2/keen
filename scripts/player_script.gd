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
var dying = false
var die_timer = 0

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
	set_fixed_process(true)
	get_node("screen_glow").show()
	if !init_face_right:
		facing = "left"
		get_node("AnimatedSprite").set_flip_h(true)

func _fixed_process(delta):
	# The Death Timer
	if dying:
		die_timer += delta
		if die_timer > 3:
			post_die()
		
	# Get Player Input
	var get_input_allowed = true
	var left_pressed = false
	var right_pressed = false
	var up_pressed = false
	var down_pressed = false
	var jump_pressed = false
	var jump_just_pressed = false
	var pogo_just_pressed = false
	var fire_shot_pressed = false
	
	if dying || entering_door || climbing:
		get_input_allowed = false
		
	if get_input_allowed:
		left_pressed = Input.is_action_pressed("ui_left")
		right_pressed = Input.is_action_pressed("ui_right")
		up_pressed = Input.is_action_pressed("ui_up")
		down_pressed = Input.is_action_pressed("ui_down")
		jump_pressed = Input.is_action_pressed("jump")
		jump_just_pressed = Input.is_action_just_pressed("jump")
		pogo_just_pressed = Input.is_action_just_pressed("pogo")
		fire_shot_pressed = Input.is_action_pressed("fire_shot")
		
	if !climbing && !entering_door:
		# Movement
		var movement = 0
		
		if (left_pressed && !shooting):
			get_node("AnimatedSprite").set_flip_h(true)
			movement -= 1
			if on_pole && !down_pressed && !up_pressed:
				on_pole = false
				force_jump_anim = true
			if !facing == "left" && on_ledge:
					on_ledge = false
					get_node("AnimationPlayer").set_current_animation("falling_down")
			facing = "left"
		
		if (right_pressed && !shooting):
			get_node("AnimatedSprite").set_flip_h(false)
			movement +=1
			if on_pole && !down_pressed && !up_pressed:
				on_pole = false
				force_jump_anim = true
			if !facing == "right" && on_ledge:
					on_ledge = false
					get_node("AnimationPlayer").set_current_animation("falling_down")
			facing = "right"
		
		movement *= MOVEMENT_SPEED
		
		# Change horizontal velocity
		if !dying:
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
			
			if (self.get_pos().y > pole_bot-5 && !up_pressed && !down_pressed):
				on_pole = false
				at_bot = true
			
			if (up_pressed && !at_top):
				p_movement -= 1
		
			if (down_pressed && !at_bot):
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
			jump_off_pole = false
			
		if (touching_pole && !on_pogo):
			if (up_pressed || down_pressed):
				if self.get_pos().y < pole_top && up_pressed:
					on_pole = false
				elif self.get_pos().y > pole_bot - 1 && down_pressed:
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
		
		if can_jump:
			jump_off_pole = false
		 
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
		if jump_just_pressed:
			wants_to_jump = true
			wants_to_jump_timer = 0
		if !on_pogo && !shooting && (allow_jump || can_jump) && wants_to_jump:
			wants_to_jump = false
			if (on_pole && !up_pressed && !down_pressed):
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
		
		if pogo_just_pressed && !shooting && !jump_off_pole:
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
			if can_jump && jump_pressed:
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
		if on_door && up_pressed && can_jump:
			self.set_pos(Vector2(door_node.get_pos().x + (door_node.width / 2), self.get_pos().y))
			get_node("AnimationPlayer").set_current_animation("enter_door")
			entering_door = true
			get_parent().get_node("light_effects/fade_screen").fade_out()
		
		# Animations
		if on_ledge:
			get_node("AnimationPlayer").set_current_animation("hanging")
		if on_pole && !force_jump_anim:
			if (up_pressed && !down_pressed && get_node("AnimationPlayer").get_current_animation() != "up_pole") || at_top || at_bot:
				get_node("AnimationPlayer").set_current_animation("up_pole")
			elif down_pressed && !up_pressed && get_node("AnimationPlayer").get_current_animation() != "down_pole":
				get_node("AnimationPlayer").play("down_pole")
			elif (!up_pressed && !down_pressed) || (up_pressed && down_pressed):
				get_node("AnimationPlayer").play("pole_idle")
		if can_jump && !on_pole && !on_pogo && !on_ledge && !shooting && !entering_door:
			if left_pressed || right_pressed:
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
		if on_ledge && facing == "right" && right_pressed && velocity.y == 0:
			climbing = true
			get_node("AnimationPlayer").set_current_animation("climbing")
		if on_ledge && facing == "left" && left_pressed && velocity.y == 0:
			climbing = true
			get_node("AnimationPlayer").set_current_animation("climbing")
		if !entering_door && !shooting && can_jump && !on_pole && !on_pogo && !on_ledge && fire_shot_pressed && up_pressed:
			shot_type = "shoot_up_standing"
			shooting = true
			get_node("AnimationPlayer").set_current_animation(shot_type)
		if !entering_door && !shooting && can_jump && !on_pole && !on_pogo && !on_ledge && fire_shot_pressed:
			shot_type = "shoot_standing"
			shooting = true
			get_node("AnimationPlayer").set_current_animation(shot_type)
		if !entering_door && !shooting && !on_pogo && !can_jump && fire_shot_pressed:
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
	get_node("Camera2D").clear_current()
	set_camera_limits(door_node.new_scene_top_left.x, door_node.new_scene_top_left.y, door_node.new_scene_bot_right.x, door_node.new_scene_bot_right.y)
	self.set_pos(door_node.other_door_location)
	get_node("AnimationPlayer").play("idle")
	entering_door = false
	get_node("Camera2D").make_current()
	get_parent().get_node("light_effects/fade_screen").fade_in()

func set_camera_limits( left, top, right, bottom ):
	get_node("Camera2D").set_limit(MARGIN_TOP, top)
	get_node("Camera2D").set_limit(MARGIN_LEFT, left)    
	get_node("Camera2D").set_limit(MARGIN_RIGHT, right)
	get_node("Camera2D").set_limit(MARGIN_BOTTOM, bottom)
	
func freeze_camera():
	var c = get_node("Camera2D").get_camera_screen_center()
	get_node("Camera2D").set_limit(MARGIN_TOP, c.y - 120)
	get_node("Camera2D").set_limit(MARGIN_LEFT, c.x - 160)    
	get_node("Camera2D").set_limit(MARGIN_RIGHT, c.x + 160)
	get_node("Camera2D").set_limit(MARGIN_BOTTOM, c.y + 120)
	
func post_die():
	get_tree().reload_current_scene()

func _on_ledge_det_body_enter( body ):
	if body.get_name() == "Main TileMap":
		on_ledge = true


func _on_ledge_det_body_exit( body ):
	if body.get_name() == "Main TileMap":
		on_ledge = false

func _on_body__col_area_enter( area ):
	var body = area.get_parent()
	
	if body.has_node("door_col"):
		door_node = body
		on_door = true
	
	if area.get_name() == "drop_col":
		body.die()
		
	if area.get_name() == "death_col" && !climbing && !entering_door && abs(self.get_pos().y - get_node("Camera2D").get_camera_screen_center().y) < 120:
		dying = true
		get_node("CollisionShape2D").set_trigger(true)
		get_node("CollisionShape2D2").set_trigger(true)
		freeze_camera()
		velocity.y = -150
		velocity.x = rand_range(-150, 150)
		if get_node("screen_glow").is_visible():
			get_parent().get_node("light_effects/screen_glow").show()
			get_parent().get_node("light_effects/screen_glow").set_pos(Vector2(160, 120) + (self.get_pos() - get_node("Camera2D").get_camera_screen_center()))
			self.get_node("screen_glow").hide()
		self.set_z(5)
		get_node("AnimationPlayer").stop()
		var frame = rand_range(31,33)
		get_node("AnimatedSprite").set_frame(frame)
		die_timer = 0


func _on_body__col_area_exit( area ):
	var body = area.get_parent()
	if body.has_node("door_col"):
		if body == door_node:
			on_door = false
