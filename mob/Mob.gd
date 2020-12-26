extends Area2D

signal select_mob

const speed = 1
const step = 32 / speed

var position_cell
var path: Array

var my_owner: int

# Called when the node enters the scene tree for the first time.
func _ready():
	position_cell = Vector2(int(position.x / 32), int(position.y / 32))
	self.connect("select_mob", get_node("/root/Game"), "_Select_Mob", [self])
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
			set_process(false)
			return
		s = path.pop_front()
		p = 0
		return
	
	match s:
			1: position += Vector2(-speed, -speed)	# left up
			2: position += Vector2(0, -speed) 		# up
			3: position += Vector2(speed, -speed) 	# right up
			4: position += Vector2(speed, 0) 		# right
			5: position += Vector2(speed, speed) 	# right down
			6: position += Vector2(0, speed) 		# down
			7: position += Vector2(-speed, speed) 	# left down
			8: position += Vector2(-speed, 0) 		# left 

func _click_cell(pos):
	if pos == position_cell:
		get_node("/root/Game").select_mob = self
		print("Select: ", get_node("/root/Game").select_mob.name)
#		emit_signal("select_mob")

func attack():
	pass

func move(pos, path):
	position_cell = pos
	self.path += path
	set_process(true)
