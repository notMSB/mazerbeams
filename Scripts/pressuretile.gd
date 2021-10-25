extends Sprite

func _on_pressure_body_entered(_body):
	visible = true

func _on_pressure_body_exited(_body):
	visible = false
