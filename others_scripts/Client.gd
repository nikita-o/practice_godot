extends Node

export (String) var host = "localhost"
export (int) var port = 11000
export (String) var name_client = "anonym"

var connection: StreamPeerTCP
var listen_thread: Thread
var send_thread: Thread

enum response {hi, mes, spawn, attack, move}
enum request {login, spawn, move}

func _ready():
	set_process(false)
	return
	
	connection = StreamPeerTCP.new()
	listen_thread = Thread.new()
	send_thread = Thread.new()

var m: String
var c: float = 2

func _process(delta):
	connection.connect_to_host(host, port)
	
	match connection.get_status():
		StreamPeerTCP.STATUS_CONNECTED:
			m = "Connected to %s:%d"
			auth()
			listen_thread.start(self, "_listener")
			set_process(false)
		StreamPeerTCP.STATUS_CONNECTING:
			m = "Trying to connect %s:%d"
		StreamPeerTCP.STATUS_ERROR:
			m = "Error connect to %s:%d"
			set_process(false)
		StreamPeerTCP.STATUS_NONE:
			m  = "Couldn't connect to %s:%d"
	
	c += delta
	if c > 1.5:
		print(m % [host, port])
		c = 0

func _listener(d):
	while true:
		var pac = connection.get_32()
		var count = connection.get_32()
		for i in count:
			match pac:
				request.login:
					print("login success! To %s:%d" % [host, port])
				request.spawn:
					pass
				request.move:
					pass

func _sender(type_packet, count, data):
	var buffer = StreamPeerBuffer.new()
	
	buffer.put_32(type_packet)
	buffer.put_32(count)
	buffer.put_data(data.data_array)
	
	connection.put_data(buffer.data_array)

#===============================================================================

func auth():
	var data = StreamPeerBuffer.new()
	data.put_8(1) # ¯\_(ツ)_/¯
	data.put_string(name_client) # name client
	data.put_32(0) # maybe message
	send_thread.start(self, "_sender", [response.hi, 1, data]) 
	
#	buffer.put_32(response.hi) # type packet
#	buffer.put_32(1) # count packets
#	buffer.put_8(1) # 
#	buffer.put_string(name_client) # name client
#	buffer.put_32(0) # message
#	connection.put_data(buffer.data_array) 

#func spawn_unit(id, count = 1):
#	var buffer = StreamPeerBuffer.new()
#	buffer.put_32(response.spawn)
#	buffer.put_32(count)
#	buffer.put_32(id)
#	connection.put_data(buffer.data_array)
