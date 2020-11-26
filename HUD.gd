extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


#signal start_game
func new_game():
	$StartButton.hide()
	$Sprite.hide()
	pass
#func _on_StartButton_pressed():
	#emit_signal("start_game")
# Called when the node enters the scene tree for the first time.
func _ready():
	$StartButton.connect("pressed",self,"new_game")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
