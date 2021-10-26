extends CanvasLayer

var restartConfirm = false
var player

func _ready():
	player = get_parent()

func toggle():
	$Items.visible = !$Items.visible
	if $Items.visible:
		$Items/restart.text = "restart"
		$Items/resume.grab_focus()
		player.menuing = true
	else:
		restartConfirm = false
		player.menuing = false

func _show_controls():
	$ControlsMenu.visible = true
	$ControlsMenu/Button.grab_focus()

func _restart():
	if restartConfirm == false:
		$Items/restart.text = "are you sure?"
		restartConfirm = true
	else:
		var error_code = get_tree().reload_current_scene()
		if error_code != OK:
			print("ERROR: ", error_code)



func _on_ControlsMenu_coolThanks():
	$Items/controls.grab_focus()
	$Items/restart.text = "restart"
	restartConfirm = false
