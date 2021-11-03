extends StaticBody2D

export (PackedScene) var Laser

#horiz false = down, horiz true + pos speed = right, horiz true + neg speed = left
export var isHorizontal = false
export var baseCountdown = 0
export var maxDuration = -1
export var laserSpeed = 5
export var activeLevel = 0 #0 means always

const fireModifier = .5
const cooldownModifier = .5

var useArrow = false
var currentDuration = -1
var countdownMultiplier = .25
var laserZ = -34 #lasers with speed 16 will have a Z of -1
onready var player = get_node("/root/Scene1/Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	laserZ = min(-1,(laserZ + abs(laserSpeed) * 2))
	if !isHorizontal:
		$Sprite.texture = load("res://assets/sprites/downspawner.png")
	elif laserSpeed < 0:
		$Sprite.texture = load("res://assets/sprites/leftspawner.png")
	else:
		$Sprite.texture = load("res://assets/sprites/rightspawner.png")
	
	if baseCountdown > 0:
		$Timer.start(cooldownModifier * baseCountdown)
	elif maxDuration > 0: #Pressure plate activated
		pass
	else:
		$Timer.start(fireModifier / abs(laserSpeed))

func fire():
	if activeLevel == player.level or activeLevel == 0:
		var proj = Laser.instance()
		owner.add_child(proj)
		proj.transform = transform
		if(useArrow):
			proj.init(player, laserSpeed, isHorizontal, useArrow, laserZ)
		else:
			proj.init(player, laserSpeed, isHorizontal, useArrow, laserZ - 2)
		useArrow = !useArrow

func _on_Timer_timeout():
	if baseCountdown > 0:
		if currentDuration < 0:
			currentDuration = maxDuration
			useArrow = true #reset to avoid staggered arrow usage on odd durations
			$Timer.start(fireModifier / abs(laserSpeed))
		elif currentDuration == 0:
			$Timer.start(cooldownModifier * baseCountdown)
			currentDuration -=1
	if currentDuration > 0:
		currentDuration -= 1
		fire()
	elif maxDuration == -1:
		fire()


func _on_P_body_entered(_body):
	useArrow = true
	currentDuration = maxDuration
	$Timer.start(fireModifier / abs(laserSpeed))
