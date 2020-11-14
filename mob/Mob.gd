extends Area2D

signal select_mob

const speed = 1
const step = 32 / speed

var position_cell
var path: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	position_cell = Vector2(int(position.x / 32), int(position.y / 32))
	self.connect("select_mob", get_node("/root/Game"), "_Select_Mob", [self])
	set_process(false)

var p = step
var s
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if p < step:
		p += 1
	else:
		if path.empty():
			position_cell = Vector2(int(position.x / 32), int(position.y / 32))
			set_process(false)
			return
		s = path.pop_back()
		p = 0
	match s:
			0: position += Vector2(speed, 0) 		# ->
			1: position += Vector2(-speed, 0) 		# <-
			2: position += Vector2(0, speed) 		# /\
			3: position += Vector2(0, -speed) 		# \/
			4: position += Vector2(speed, speed) 	# \/ ->
			5: position += Vector2(-speed, -speed) 	# /\ <-
			6: position += Vector2(speed, -speed) 	# \/ <-
			7: position += Vector2(-speed, speed) 	# /\ ->

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == BUTTON_LEFT:
			var mouse_pos = get_global_mouse_position() / 32
			mouse_pos = Vector2(int(mouse_pos.x) , int(mouse_pos.y))
			var player_pos = position / 32
			player_pos = Vector2(int(player_pos.x) , int(player_pos.y))
			if mouse_pos == player_pos:
				emit_signal("select_mob")

func move(path):
	if !self.path.empty():
		return
	self.path = path
	set_process(true)
