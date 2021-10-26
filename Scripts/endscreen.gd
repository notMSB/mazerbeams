extends Control

func _ready():
	$"Gart Menu/Button".grab_focus()

func _on_Button_pressed():
	get_tree().change_scene("res://scenes/menu.tscn")
