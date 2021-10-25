extends Area2D

var readySprite = preload("res://assets/sprites/restoreready.png")
var usedSprite = preload("res://assets/sprites/restoreused.png")

var isReady = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Timer_timeout():
	isReady = true
	$CollisionShape2D/Sprite.set_texture(readySprite) 

func _on_restore(body):
	if !body.canDash and isReady:
		body.canDash = true
		body.setSprite()
		isReady = false
		$CollisionShape2D/Sprite.set_texture(usedSprite)
		$Timer.start(2)
