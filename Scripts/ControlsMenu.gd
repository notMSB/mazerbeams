extends ColorRect

signal coolThanks

func _on_Button_pressed():
	set_visible(false)
	emit_signal("coolThanks")
