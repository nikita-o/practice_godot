extends Control

func _on_continue_pressed():
	visible = false

func _on_Surrender_pressed():
	Client._action(8, Vector2.ZERO, 0)

func _on_Cheat_pressed():
	Client._action(7, Vector2.ZERO, 0)
