extends Control

func _ready():
	if Storage.win:
		$ColorRect/Label.text = "YOU WIN!"
	else:
		$ColorRect/Label.text = "YOU LOSE!"

func _on_Button_pressed():
	var _err = get_tree().change_scene("res://Main_menu.tscn")
