extends Control

func _on_Button_pressed():
	print("Exit!")
	get_tree().quit()
	pass

func _on_Start_pressed():
	Client.start_game()
#	get_tree().change_scene("res://Game.tscn")

func _on_Authors_pressed():
	print("dayni")
