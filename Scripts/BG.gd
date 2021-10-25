extends CanvasLayer

func changeBG(playerYpos):
	if playerYpos < -1600:
		$Sprite.modulate = Color(.85, .65, .12)
	elif playerYpos < -1080:
		$Sprite.modulate = Color(.75, .75, .75)
	elif playerYpos < -280:
		$Sprite.modulate = Color(.69, .55, .34)
	else:
		$Sprite.modulate = Color(.53, .51, .48)
