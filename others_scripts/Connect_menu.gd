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
	Client.host = String(get_node("host").text)
	Client.port = int(get_node("port").text)
	Client.client_name = get_node("login").text
	Client.client_password = get_node("password").text
	Client.connect_to_server()
