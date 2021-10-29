extends Control

func _ready():
	$MainMenu/Button.grab_focus()
	var save_game = File.new()
	if save_game.file_exists("user://savegame.save"):
		$MainMenu/Button.text = "resume"
	
func _play_button():
	var error_code = get_tree().change_scene("res://scenes/Scene1.tscn")
	if error_code != OK:
		print("ERROR: ", error_code)

func _show_controls():
	$ControlsMenu.visible = true
	$ControlsMenu/Button.grab_focus()


func _on_ControlsMenu_coolThanks():
	$MainMenu/Button.grab_focus()

