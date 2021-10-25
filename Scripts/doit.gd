extends Area2D

var counter = 0

func _on_funny_body_exited(_body):
	if counter < 2:
		counter+=1
	if counter >= 1:
		$doit.visible = true
	if counter >= 2:
		$uwont.visible = true
