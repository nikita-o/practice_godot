extends Node

var host: String = "localhost"
var port: int = 11000

var connection: StreamPeerTCP = StreamPeerTCP.new()
var checkThread: Thread = Thread.new()
var listener: Thread = Thread.new()
var client_name: String
var client_password: String

var id_player: int

var turn: bool = false

enum response {
	connect = 1, 
	accept = 3,
	message = 4, 
	Ping = 5,
	ErrorPocket = 10,
	InitGame = 11,
	EndGame = 13,
	SelectUnit  = 20, 
	MoveUnit    = 21, 
	Attack      = 22, 
	SpawnUnit   = 23, 
	UpgradeTown = 24, 
	Market      = 25, 
	CaptureMine = 26, 
	nextTurn    = 27,
	Resources	= 28,
	}

enum request {
	connect = 1,
	action = 9,
	start_game = 12,
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
signal UpdateResources(id, Gold, Wood, Rock, Crystall)

func _ready():
	print(123)
	pass

func _process(delta):
	pass

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

func disconnect_server():
	listener.wait_to_finish()
	checkThread.wait_to_finish()
	get_tree().change_scene("res://Connect_menu.tscn")
#	get_tree().quit()

func _checkConnect(prm):
	while (true):
		if connection.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			print("Lost connect!")
			self.call_deferred("disconnect_server")
			return
		yield(get_tree().create_timer(3.0), "timeout")

func _listener(d):
	while connection.get_status() == StreamPeerTCP.STATUS_CONNECTED:
#		print("________________")
		var _id = connection.get_32()
#		print("_id: ", _id)
		var pac = connection.get_32()
#		print("Packet: ", pac)
		var size = connection.get_32()
#		print("Size: ", size)
#		print("================")
		match pac:
			response.accept:
				var huynya = connection.get_32()
			response.connect:
				var Name = connection.get_string()
				var Message = connection.get_string()
				print("connect")
				get_tree().change_scene("res://Main_menu.tscn")
			response.Ping:
				var Tick = connection.get_32()
				var LastPing = connection.get_32()
			response.InitGame:
				var id = connection.get_32()
				print("InitGame: ", id)
				id_player = id
				get_tree().change_scene("res://Game.tscn")
			response.EndGame:
				var id = connection.get_32()
				var place = connection.get_32()
				print("END GAME!!! ", id, " ", place)
			response.message:
				print("message")
			response.SelectUnit:
				var id = connection.get_32()
				var position = Vector2(connection.get_32(), connection.get_32())
				print("SelectUnit")
				self.call_deferred("emit_signal", "SelectUnit", position)
			response.MoveUnit:
				var id = connection.get_32()
				var position = Vector2(connection.get_32(), connection.get_32())
				var actionPoints = connection.get_32()
				var path = []
				for j in connection.get_32():
					path.push_back(connection.get_32())
				print("MoveUnit")
				self.call_deferred("emit_signal", "MoveUnit", position, path, actionPoints)
			response.Attack:
				var atack_id = connection.get_32()
				var atack_position = Vector2(connection.get_32(), connection.get_32())
				var atack_health = connection.get_32()
				var defens_id = connection.get_32()
				var defens_position = Vector2(connection.get_32(), connection.get_32())
				var defens_health = connection.get_32()
				print("Attack", defens_health, defens_position)
				self.call_deferred("emit_signal", "Attack",defens_health, defens_position)
			response.SpawnUnit:
				var id = connection.get_32()
				var position = Vector2(connection.get_32(), connection.get_32())
				var type_unit = connection.get_32()
				var attack = connection.get_32()
				var defense = connection.get_32()
				var damage = connection.get_32()
				var health = connection.get_32()
				var MAXactionPoints = connection.get_32()
				var rangeAttack = connection.get_32()
				var shootingDamage = connection.get_32()
				print("SpawnUnit")
				self.call_deferred("emit_signal", "SpawnUnit", position, type_unit, attack, defense, damage, health, MAXactionPoints, rangeAttack, shootingDamage)
			response.UpgradeTown:
				var id = connection.get_32()
				var level = connection.get_32()
				var health = connection.get_32()
				print("UpgradeTown")
				self.call_deferred("emit_signal","UpgradeTown", level, health)
			response.Market:
				print("Market")
				self.call_deferred("emit_signal","Market")
			response.CaptureMine:
				var id = connection.get_32()
				var position = Vector2(connection.get_32(), connection.get_32())
				var type_cave = connection.get_32()
				print("CaptureMine")
				self.call_deferred("emit_signal","CaptureMine", position)
			response.Resources:
				var id = connection.get_32()
				var gold = connection.get_32()
				var wood = connection.get_32()
				var rock = connection.get_32()
				var crystall = connection.get_32()
				self.call_deferred("emit_signal","UpdateResources", gold, wood, rock, crystall)
			response.nextTurn:
				var id = connection.get_32()
				print("nextTurn: ", id, " ME ", id_player)
				if id_player == id:
					turn = true
				else:
					turn = false
			response.ErrorPocket:
				var id_error = connection.get_32()
				var error_message = connection.get_string()
				
				print("ErrorPocket: ", id_error, " mes: ", error_message)
#		print("________________\n")

func send_packet(type, data: StreamPeerBuffer):
	var buffer = StreamPeerBuffer.new()
	buffer.put_32(OS.get_unix_time()) # id (not work)
	buffer.put_32(type) # type packet
	buffer.put_32(data.get_size()) # size packets
	buffer.put_data(data.data_array) # data in packet
	connection.put_data(buffer.data_array) # send to server

func auth():
	print("Name: ", client_name)
	print("Password: ", client_password)
	var data = StreamPeerBuffer.new()
	data.put_string(client_name) # name client
	data.put_string(client_password) # message
	send_packet(request.connect, data)

func start_game():
	var data = StreamPeerBuffer.new()
	data.put_32(0)
	data.put_32(3)
	send_packet(request.start_game, data)

func _action(button: int, pos: Vector2, param: int):
	if !turn: 
		print("not our turn!")
		return
	var data = StreamPeerBuffer.new()
	data.put_32(button)
	data.put_32(pos.x)
	data.put_32(pos.y)
	data.put_32(param)
	send_packet(request.action, data)
