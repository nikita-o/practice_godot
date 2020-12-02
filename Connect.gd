extends Control

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_exit_pressed():
	get_tree().quit()

func _on_connect_pressed():
	print("Connecting...")
	Connecting.client_name = get_node("login").text
	Connecting.client_password = get_node("password").text
	Connecting.connect_to_server()
