extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _on_Button_pressed():
	print("2")
	get_tree().quit()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print("1")
	pass


func _on_Start_pressed():
	print("3")
	get_tree().change_scene("res://Game.tscn")
	pass # Replace with function body.


func _on_Authors_pressed():
	print("dayni")
	pass # Replace with function body.
