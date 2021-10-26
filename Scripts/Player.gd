extends KinematicBody2D

export (PackedScene) var Afterimage

var defaultSprite = preload("res://assets/sprites/player.png")
var ndSprite = preload("res://assets/sprites/playerND.png")
var kbSprite = preload("res://assets/sprites/playerKB.png")
var kbndSprite = preload("res://assets/sprites/playerKBND.png")

var background

#Idle, Laser Immunity, Wallstick, Predash, Dash, Knockback
enum SL {S_ID, S_IM, S_ST, S_PD, S_DA, S_KB}
var state = SL.S_ID

var velocity = Vector2(0,0)
var canDash = true
var horizDir = 1
var laserHoriz
var laserThru = false
var stickyTimer = 0
var laserStuck = false
var wallLeniencyFrames = 0
var menuing = false
var endfade
var gart = false

const SPEED = 450
const GRAVITY = 60
const JUMPFORCE = -750
const dashX = SPEED
const dashY = JUMPFORCE * .5
const dashTime = .2
const laserSpeedMultiplier = 60
const stickyTotal = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	background = get_node("../BG")

func _physics_process(delta):
	#states that disallow air drift are barred, and moving grounded while not idle or crouching is barred
	if gart:
		endfade.modulate.a += .005
		if endfade.modulate.a >= 1:
			var error_code = get_tree().change_scene("res://scenes/congart.tscn")
			if error_code != OK:
				print("ERROR: ", error_code)
	if Input.is_action_just_pressed("togglemenu"):
		$EscMenu.toggle()
	if !menuing:
		if state == SL.S_ST:
			stickyTimer -=1
			if velocity.x != 0 or stickyTimer <= 0:
				changeState(SL.S_ID)
			else:
				var col = move_and_collide(Vector2(horizDir,0)) #hacky way to figure out if you're on a wall
				if !col:
					changeState(SL.S_ID)
					position.x+= -1*horizDir #unhacking after the slide ends
		if(is_on_floor() and !canDash and state != SL.S_DA):
			canDash = true
			setSprite()
		if state <= 2:
			if Input.is_action_pressed("right") and !Input.is_action_pressed("left"): #Double direction does nothing
				moveDir(1)
			elif Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
				moveDir(-1)
		if state != SL.S_KB:
			if Input.is_action_just_pressed("jump"):
				jump()
			if Input.is_action_just_released("jump") and !(is_on_floor()):
				if velocity.y < -200:
					velocity.y = -200
		
		if Input.is_action_just_pressed("dash") and canDash:
			changeState(SL.S_PD)
	
	#Reset dash speed if dashing around a wall zeroes it out; canDash is checked to filter dedicated dashes from walljumps
	if state == SL.S_DA and velocity.x == 0 and !is_on_wall() and !canDash:
		velocity.x = SPEED * horizDir * 2
		#print("correction")
	if state != SL.S_KB:
		velocity = move_and_slide(velocity, Vector2.UP)
	else:
		var collision = move_and_collide(velocity * delta)
		if collision:
			#print(collision.normal.x)
			changeState(SL.S_IM)
	if state <= 2:
		velocity.x = lerp(velocity.x, 0, 0.3)
		if(is_on_wall()) or state == SL.S_ST:
			velocity.y = min(100, velocity.y + GRAVITY)
			if wallLeniencyFrames > 0:
				wallLeniencyFrames = 0
		else:
			velocity.y += GRAVITY
			if wallLeniencyFrames < 4:
				wallLeniencyFrames +=1

func setSprite():
	if canDash:
		if state != SL.S_KB:
			$Sprite.set_texture(defaultSprite)
		else:
			$Sprite.set_texture(kbSprite)
	elif state != SL.S_KB or state == SL.S_PD:
		$Sprite.set_texture(ndSprite)
	else:
		$Sprite.set_texture(kbndSprite)

func moveDir(dir):
	horizDir = dir
	velocity.x = lerp(velocity.x, max(SPEED, abs(velocity.x)) * dir, 0.35)
	if is_on_floor():
		velocity.y += GRAVITY

func jump():
	var canJump = false
	if is_on_floor():
		changeState(SL.S_ID)
		velocity.y = JUMPFORCE
	elif is_on_wall() or (state == SL.S_DA and (velocity.x == 0)) or state == SL.S_ST:
		canJump = true
	elif wallLeniencyFrames < 4:
		var col = move_and_collide(Vector2(horizDir, 0))
		if col:
			print("leniency")
			canJump = true
	if canJump:
		var collision = move_and_collide(Vector2(horizDir, 0))
		if collision:
			if collision.collider.name == "J":
				horizDir = horizDir * -1
				velocity.x = dashX * horizDir
				velocity.y = dashY
				#Treating it as a dash
				changeState(SL.S_DA)

	
func dash():
	if Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		horizDir = 1
	elif Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		horizDir = -1
	velocity.x = dashX * horizDir
	if Input.is_action_pressed("up") and !Input.is_action_pressed("down"):
		velocity.y = dashY
	elif Input.is_action_pressed("down") and (!(is_on_floor()) or state == SL.S_KB) and !Input.is_action_pressed("up"):
		velocity.y = dashY * -1
	elif not is_on_floor():
		velocity.y = 0
	changeState(SL.S_DA)
	canDash = false
	setSprite()
	
func changeState(newState):
	#print(newState)	
	if state == SL.S_KB and laserStuck:
		laserStuck = false
	if state == SL.S_DA and velocity.x == 0:
		newState = SL.S_ST
	state = newState
	if newState == SL.S_ST:
		stickyTimer = stickyTotal
	if newState != SL.S_KB and laserThru:
		laserThru = false
	if newState == SL.S_IM: #bit 3 is lasers, bit 4 is platforms
		set_collision_mask_bit(3, 0)
		set_collision_mask_bit(4, 1)
		$Timer.start(.15)
	if newState == SL.S_ID:
		set_collision_mask_bit(3, 1)
		set_collision_mask_bit(4, 1)
	elif newState == SL.S_PD:
		set_collision_mask_bit(3, 0)
		set_collision_mask_bit(4, 1)
		$Timer.start(.05)
	elif newState == SL.S_DA:
		set_collision_mask_bit(3, 0)
		set_collision_mask_bit(4, 1)
		createAfterimages()
		$Timer.start(dashTime)
	elif newState == SL.S_KB:
		set_collision_mask_bit(4, 0)
	setSprite()

func createAfterimages():
	var trail = Afterimage.instance()
	owner.add_child(trail)
	trail.set_z_index(-1)
	trail.transform = transform
	trail.init($Sprite.texture)

func _on_Timer_timeout():
	#print(state)
	if state == SL.S_PD:
		changeState(SL.S_DA)
		dash()
	elif state == SL.S_IM:
		changeState(SL.S_ID)
	elif state == SL.S_DA:
		#makes sure is_on_floor is intuitively correct, i think?
		velocity = move_and_slide(Vector2(velocity.x, velocity.y + GRAVITY / 10.0), Vector2.UP)
		
		velocity = Vector2(0,0)
		changeState(SL.S_ID)


func hitByLaser(travelSpeed, isHoriz, laserPos):
	#print("hit")
	laserHoriz = isHoriz
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "C":
			laserThru = true
		
	if (isHoriz and (!is_on_wall()) or (is_on_wall() and travelSpeed * horizDir < 1)) or (!isHoriz and (!is_on_floor() or laserThru or state == SL.S_KB)):
		#	print("travel")
		if !isHoriz and !(state == SL.S_KB and abs(velocity.x / 60) >= abs(travelSpeed)):
			if !laserStuck:
				position.x = laserPos.x
				laserStuck = true
			velocity = Vector2(0, travelSpeed) * laserSpeedMultiplier
		elif isHoriz and !(state == SL.S_KB and abs(velocity.y / 60) >= abs(travelSpeed)):
			horizDir = travelSpeed / abs(travelSpeed)
			if !laserStuck:
				position.y = laserPos.y
				laserStuck = true
			velocity = Vector2(travelSpeed, 0) * laserSpeedMultiplier
		changeState(SL.S_KB)

func _on_BGDeciders_body_entered(_body):
	background.changeBG(position.y)

func _win(_body):
	endfade = get_node("../endfade")
	endfade.visible = true
	gart = true
