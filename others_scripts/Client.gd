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
	AttackTown	= 29,
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
	right_click = 5,
	cheats = 6,
	give_up = 7,
	}

signal SelectUnit
signal MoveUnit
signal Attack
signal SpawnUnit
signal UpgradeTown
signal Market
signal CaptureMine
signal UpdateResources
signal AttackTown

func _ready():
	pass

#func _process(delta):
#	pass

func connect_to_server():
	var m: String
	while (true):
		var _err = connection.connect_to_host(host, port)
		match connection.get_status():
			StreamPeerTCP.STATUS_CONNECTED:
				m = "Connected to %s:%d"
				auth()
				_err = checkThread.start(self, "_checkConnect")
				_err = listener.start(self, "_listener")
				break
			StreamPeerTCP.STATUS_CONNECTING:
				m = "Trying to connect %s:%d"
			StreamPeerTCP.STATUS_ERROR:
				m = "Error connect to %s:%d"
			StreamPeerTCP.STATUS_NONE:
				m  = "Couldn't connect to %s:%d"
		print(m % [host, port])
		yield(get_tree().create_timer(1.0), "timeout")
	print()

func disconnect_server():
	print("\nLost connect!\n")
	listener.wait_to_finish()
	checkThread.wait_to_finish()
	var _err = get_tree().change_scene("res://Connect_menu.tscn")

func _checkConnect(_prm):
	while (true):
		if connection.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			self.call_deferred("disconnect_server")
			return
		yield(get_tree().create_timer(3.0), "timeout")

func print_head_packet(id, pac, size):
	print("\n==========")
	print("header")
	print("id: ", id)
	print("packet: ", pac)
	print("size: ", size)
	print("==========")

func accept():
	print("\taccept packet!")

func accept_connect(Name, Message):
	print("\tconnect - ", Name, " - ", Message)
	var _err = get_tree().change_scene("res://Main_menu.tscn")

func init_game(id):
	print("\tInitGame: ", id)
	id_player = id
	var _err = get_tree().change_scene("res://Game.tscn")

func update_resources(gold, wood, rock, crystall):
	emit_signal("UpdateResources", gold, wood, rock, crystall)

func end_game(id, place):
	print("\tEND GAME!!! ", id, " ", place)
	if id_player == id: print("\tYOU WIN!")
	else: print("\tYOU LOSE!")
	var data = StreamPeerBuffer.new()
	data.put_32(0)
	data.put_32(5)
	send_packet(request.start_game, data)
#	END GAME
	var _err = get_tree().change_scene("res://Main_menu.tscn")

func next_turn(id):
	print("\tnextTurn: ", id, " ME ", id_player)
	if id_player == id: turn = true
	else: turn = false

func error_packet(id, msg):
	print("\tErrorPocket: ", id, " msg: ", msg)

func _listener(_prm):
	while connection.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var id_packet = connection.get_32()
		var packet = connection.get_32()
		var size = connection.get_32()
		self.call_deferred("print_head_packet", id_packet, packet, size)
		match packet:
			response.accept:
				var _f = connection.get_32()
				self.call_deferred("accept")
			response.connect:
				var Name = connection.get_string()
				var Message = connection.get_string()
				self.call_deferred("accept_connect", Name, Message)
			response.Ping:
				var Tick = connection.get_32()
				var LastPing = connection.get_32()
				self.call_deferred("ping", Tick, LastPing)
			response.InitGame:
				var _id = connection.get_32()
				self.call_deferred("init_game", _id)
			response.EndGame:
				var _id = connection.get_32()
				var place = connection.get_32()
				self.call_deferred("end_game", _id, place)
			response.SelectUnit:
				var _id = connection.get_32()
				var position = Vector2(connection.get_32(), connection.get_32())
				var action_points = connection.get_32()
				if (_id == id_player):
					self.call_deferred("emit_signal", "SelectUnit", position, action_points)
			response.MoveUnit:
				var _id = connection.get_32()
				var e_position = Vector2(connection.get_32(), connection.get_32())
				var s_position = Vector2(connection.get_32(), connection.get_32())
				var actionPoints = connection.get_32()
				var path = []
				for j in connection.get_32():
					path.push_back(connection.get_32())
				self.call_deferred("emit_signal", "MoveUnit", s_position, path, actionPoints, e_position)
			response.Attack:
				var _atack_id = connection.get_32()
				var _atack_position = Vector2(connection.get_32(), connection.get_32())
				var _atack_health = connection.get_32()
				var _defens_id = connection.get_32()
				var _defens_position = Vector2(connection.get_32(), connection.get_32())
				var _defens_health = connection.get_32()
				self.call_deferred("emit_signal", "Attack", _defens_health, _defens_position)
			response.AttackTown:
				var _unit_id = connection.get_32()
				var _unit_position = Vector2(connection.get_32(), connection.get_32())
				var _unit_health = connection.get_32()
				var _town_id = connection.get_32()
				var _town_position = Vector2(connection.get_32(), connection.get_32())
				var _town_health = connection.get_32()
				self.call_deferred("emit_signal", "AttackTown", _town_health)
			response.SpawnUnit:
				var _id = connection.get_32()
				var _position = Vector2(connection.get_32(), connection.get_32())
				var _type_unit = connection.get_32()
				var _attack = connection.get_32()
				var _defense = connection.get_32()
				var _damage = connection.get_32()
				var _health = connection.get_32()
				var _MAXactionPoints = connection.get_32()
				var _rangeAttack = connection.get_32()
				var _shootingDamage = connection.get_32()
				self.call_deferred("emit_signal", "SpawnUnit", _position, _type_unit, _attack, _defense, _damage, _health, _MAXactionPoints, _rangeAttack, _shootingDamage)
			response.UpgradeTown:
				var _id = connection.get_32()
				var level = connection.get_32()
				var health = connection.get_32()
				self.call_deferred("emit_signal","UpgradeTown", level, health)
			response.Market:
				self.call_deferred("emit_signal","Market")
			response.CaptureMine:
				var _id = connection.get_32()
				var _position = Vector2(connection.get_32(), connection.get_32())
				var _type_cave = connection.get_32()
				self.call_deferred("emit_signal","CaptureMine", _position)
			response.Resources:
				var _id = connection.get_32()
				var gold = connection.get_32()
				var wood = connection.get_32()
				var rock = connection.get_32()
				var crystall = connection.get_32()
				self.call_deferred("update_resources", gold, wood, rock, crystall)
#				self.call_deferred("emit_signal","UpdateResources", gold, wood, rock, crystall)
			response.nextTurn:
				var _id = connection.get_32()
				self.call_deferred("next_turn", _id)
			response.ErrorPocket:
				var id_error = connection.get_32()
				var error_message = connection.get_string()
				self.call_deferred("error_packet", id_error, error_message)

func send_packet(type, data: StreamPeerBuffer):
	var buffer = StreamPeerBuffer.new()
	buffer.put_32(OS.get_unix_time()) # id (not work)
	buffer.put_32(type) # type packet
	buffer.put_32(data.get_size()) # size packets
	buffer.put_data(data.data_array) # data in packet
	print("\n~~~~~~~~~~")
	print("SEND PACKET = ", type)
	print("ERROR = ", connection.put_data(buffer.data_array)) # send to server
	print("~~~~~~~~~~\n")

func auth():
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
		print("\nNOT our turn!\n")
		return
	var data = StreamPeerBuffer.new()
	data.put_32(button)
	data.put_32(pos.x)
	data.put_32(pos.y)
	data.put_32(param)
	send_packet(request.action, data)

func ping(Tick, LastPing):
	var data = StreamPeerBuffer.new()
	data.put_32(Tick)
	data.put_32(LastPing)
	send_packet(5, data)
	print("\tping, Tick: ", Tick, " LastPing: ", LastPing)
