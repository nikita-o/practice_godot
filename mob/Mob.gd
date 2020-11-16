extends Area2D

signal select_mob
#signal block(who)

const speed = 1
const step = 32 / speed

var position_cell
var path: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	position_cell = Vector2(int(position.x / 32), int(position.y / 32))
	self.connect("select_mob", get_node("/root/Game"), "_Select_Mob", [self])
#	self.connect("block", get_node("/root/Game"), "_Select_Mob", [self])
	get_node("/root/Game").connect("click_cell", self, "_click_cell")
	get_node("/root/Game").connect("check_cell", self, "_check_cell")
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
		return
	
	match s:
			0: position += Vector2(speed, 0) 		# ->
			1: position += Vector2(-speed, 0) 		# <-
			2: position += Vector2(0, speed) 		# /\
			3: position += Vector2(0, -speed) 		# \/
			4: position += Vector2(speed, speed) 	# \/ ->
			5: position += Vector2(-speed, -speed) 	# /\ <-
			6: position += Vector2(speed, -speed) 	# \/ <-
			7: position += Vector2(-speed, speed) 	# /\ ->

func _click_cell(pos):
	if pos == position_cell:
		emit_signal("select_mob")

#func _check_cell(pos):
#	if pos == position_cell:
#		emit_signal("block", self)

func move(path):
	if !self.path.empty():
		return
	self.path = path
	set_process(true)
