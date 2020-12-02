extends Node

var listen_thread: Thread = Thread.new()
var send_thread: Thread = Thread.new()

enum response {hi, mes, spawn, attack, move}
enum request {spawn, upgrade_town, market, next_turn, left_click, right_click}

func _ready():
	listen_thread.start(self, "_listener")
	pass

func _listener(d):
	while true:
		var pac = Connecting.connection.get_32()
		var count = Connecting.connection.get_32()
		for i in count:
			match pac:
				request.spawn:
					pass
				request.move:
					pass

# send data to server, data is wrapped in packet, packet is wrapped in an array of bytes
func _sender(type_packet, count, data):
	var buffer = StreamPeerBuffer.new()
	
	buffer.put_32(type_packet)
	buffer.put_32(count)
	buffer.put_data(data.data_array)
	
	Connecting.connection.put_data(buffer.data_array)
