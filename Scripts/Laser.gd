extends Area2D

var player

var arrowUsed = false
var laserSpeed = 0
var isHorizontal = false

var perishTimer = 0
var perishing = false

func init(inheritedSpeed, isHoriz, useArrow, laserZ):
	player = get_node("../Player")
	set_z_index(laserZ)
	laserSpeed = inheritedSpeed
	perishTimer = 32 - abs(laserSpeed)
	isHorizontal = isHoriz
	arrowUsed = useArrow
	setSprite(useArrow)

func setSprite(useArrow):
	if !useArrow:
		if isHorizontal:
			$Sprite.texture = load("res://assets/sprites/laserhoriz.png")
		else:
			$Sprite.texture = load("res://assets/sprites/laservert.png")
	elif useArrow and !isHorizontal:
		$Sprite.texture = load("res://assets/sprites/downlaser.png")
	elif laserSpeed < 0:
		$Sprite.texture = load("res://assets/sprites/leftlaser.png")
	else:
		$Sprite.texture = load("res://assets/sprites/rightlaser.png")

func _physics_process(_delta):
	if(isHorizontal):
		position.x += laserSpeed
	else:
		position.y += laserSpeed
	if perishing:
		perishTimer -= abs(laserSpeed)
		if perishTimer <= 0:
			queue_free()

func _on_Laser_body_entered(body):
	if body.collision_layer == 2:
		if !arrowUsed:
			$Sprite.texture = load("res://assets/sprites/laser.png")
		perishing = true
	else:
		player.hitByLaser(laserSpeed, isHorizontal, position)
