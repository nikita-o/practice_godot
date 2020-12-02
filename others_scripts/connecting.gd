extends Node

var host: String = "localhost"
var port: int = 11000

var connection: StreamPeerTCP = StreamPeerTCP.new()
var checkThread: Thread = Thread.new()
var client_name: String
var client_password: String

func connect_to_server():
	var m: String
	while (true):
		connection.connect_to_host(host, port)
		match connection.get_status():
			StreamPeerTCP.STATUS_CONNECTED:
				m = "Connected to %s:%d"
				#auth()
				checkThread.start(self, "_checkConnect")
				break
			StreamPeerTCP.STATUS_CONNECTING:
				m = "Trying to connect %s:%d"
			StreamPeerTCP.STATUS_ERROR:
				m = "Error connect to %s:%d"
			StreamPeerTCP.STATUS_NONE:
				m  = "Couldn't connect to %s:%d"
		print(m % [host, port])
		yield(get_tree().create_timer(1.0), "timeout")
	print("Connect!")
	get_tree().change_scene("res://Main.tscn")

func _checkConnect(prm):
	while (true):
		# ping
		if connection.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			print("Lost connect!")
			# reconnect? || error
		else:
			print("Good connect!")
		yield(get_tree().create_timer(3.0), "timeout")

#func auth():
#	print("Name: ", client_name)
#	print("Password: ", client_password)
#	var data = StreamPeerBuffer.new()
#	data.put_8(1) # ¯\_(ツ)_/¯
#	data.put_string(client_name) # name client
#	data.put_32(0) # maybe message
##	send_thread.start(self, "_sender", [response.hi, 1, data]) 
