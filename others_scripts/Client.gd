extends Node

var host: String = "localhost"
var port: int = 11000

var connection: StreamPeerTCP = StreamPeerTCP.new()
var checkThread: Thread = Thread.new()
var listener: Thread = Thread.new()
#var sender: Thread = Thread.new()
var client_name: String
var client_password: String

enum response {
	connect = 1, 
	accept = 3,
	message = 4, 
	SelectUnit = 10, 
	MoveUnit = 11, 
	Attack = 12, 
	SpawnUnit = 13, 
	UpgradeTown = 14, 
	Market = 15, 
	CaptureMine = 16, 
	nextTurn = 17,
	ErrorPocket = 8
	}

enum request {
	connect = 1,
	action = 7
}

enum Buttons {
	spawn = 0, 
	upgrade_town = 1, 
	market = 2, 
	next_turn = 3, 
	left_click = 4, 
	right_click = 5
	}

signal SelectUnit(id, pos) # id player!
signal MoveUnit(id, path)
signal Attack(atack_id, atack_position, defens_id, defens_position)
signal SpawnUnit(id, position, type_unit) # id player!
signal UpgradeTown(id, level, health) # id player! (coord?)
signal Market(pos) # id player!
signal CaptureMine(id, position) # id player!
signal nextTurn(id) # id player!

#func _ready():
#	pass

func connect_to_server():
	var m: String
	while (true):
		connection.connect_to_host(host, port)
		match connection.get_status():
			StreamPeerTCP.STATUS_CONNECTED:
				m = "Connected to %s:%d"
				auth()
				checkThread.start(self, "_checkConnect")
				listener.start(self, "_listener")
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
			listener.wait_to_finish()
			get_tree().quit()
			# reconnect? || error
		else:
			print("Good connect!")
		yield(get_tree().create_timer(3.0), "timeout")

func _listener(d):
	while connection.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var _hash = connection.get_32()
		print("_hash: ", _hash)
		var _id = connection.get_32()
		print("_id: ", _id)
		var pac = connection.get_32()
		print("Packet: ", pac)
		var count = connection.get_32()
		print("count: ", count)
		match pac:
			response.accept:
				pass
			response.connect:
				var Name = connection.get_string()
				var Message = connection.get_string()
				print("connect")
				get_tree().change_scene("res://Main_menu.tscn")
			response.message:
				print("message")
			response.SelectUnit:
				var id = connection.get_32()
				var position = Vector2(connection.get_32(), connection.get_32())
				print("SelectUnit")
				emit_signal("SelectUnit", position)
			response.MoveUnit:
				var id = connection.get_32()
				var path = []
				for j in connection.get_32():
					path.push_back(connection.get_32())
				print("MoveUnit")
				print(path)
				emit_signal("MoveUnit", path)
			response.Attack:
				var atack_id = connection.get_32()
				var atack_position = Vector2(connection.get_32(), connection.get_32())
				var defens_id = connection.get_32()
				var defens_position = Vector2(connection.get_32(), connection.get_32())
				print("Attack")
				emit_signal("Attack")
			response.SpawnUnit:
				var id = connection.get_32()
				var position = Vector2(connection.get_32(), connection.get_32())
				var type_unit = connection.get_32()
				print(position)
				print("SpawnUnit")
				emit_signal("SpawnUnit", position, type_unit)
			response.UpgradeTown:
				var id = connection.get_32()
				var level = connection.get_32()
				var health = connection.get_32()
				print("UpgradeTown")
				emit_signal("UpgradeTown", level, health)
			response.Market:
				print("Market")
				emit_signal("Market")
			response.CaptureMine:
				var id = connection.get_32()
				var position = Vector2(connection.get_32(), connection.get_32())
				print("CaptureMine")
				emit_signal("CaptureMine", position)
			response.nextTurn:
				var id = connection.get_32()
				print("nextTurn")
				emit_signal("nextTurn")
			response.ErrorPocket:
				var id_error = connection.get_32()
				var error_message = connection.get_string()
				print("ErrorPocket: ", id_error, " mes: ", error_message)

func send_packet(type, count, data):
	var buffer = StreamPeerBuffer.new()
	
	buffer.put_32(332) # hash (not work)
	buffer.put_32(8888) # id (not work)
	buffer.put_32(type) # type packet
	buffer.put_32(count) # count packets
	buffer.put_data(data.data_array) # data in packet
	connection.put_data(buffer.data_array) # send to server

func auth():
	print("Name: ", client_name)
	print("Password: ", client_password)
	var data = StreamPeerBuffer.new()
	data.put_string(client_name) # name client
	data.put_string(client_password) # message
	send_packet(request.connect, 1, data)


func _action(button: int, pos: Vector2, param: int):
	var data = StreamPeerBuffer.new()
	data.put_32(button)
	data.put_32(pos.x)
	data.put_32(pos.y)
	data.put_32(param)
	send_packet(request.action, 1, data)
