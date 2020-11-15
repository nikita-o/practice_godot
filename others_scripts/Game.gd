extends Node

signal click_cell(pos)

var select_mob

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("click_cell", self, "_click_cell")
	var id = 0
	for i in get_tree().get_nodes_in_group("spawn_button"):
		i.connect("pressed", self, "spawn_unit", [id])
		id += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == BUTTON_LEFT:
			if event.position.x < get_node("/root/Game/interface/Control/Panel").get_position().x:
				if event.position.y > get_node("/root/Game/interface/Control/Panel2").get_size().y:
					var pos = get_node("Map").get_global_mouse_position() / 32
					pos = Vector2(int(pos.x) , int(pos.y))
					emit_signal("click_cell", pos)

func _click_cell(pos):
	print(pos)
	if select_mob:
		if pos != select_mob.position_cell:
			move(pos)
	pass

func _Select_Mob(mob):
	print("selected: ", mob.name)
	select_mob = mob

func spawn_unit(id, count = 1):
	print(id)

func move(coord):
	print("Move to ", coord)
	var path = []
	var x
	var y
	var path_x = coord.x - select_mob.position_cell.x
	var path_y = coord.y - select_mob.position_cell.y
	
	if path_x < 0: 
		x = 1
		path_x *= -1
	else: 
		x = 0
	
	if path_y < 0:
		y = 3
		path_y *= -1
	else:
		y = 2
	
	for i in path_x:
		path.push_back(x)
	for i in path_y:
		path.push_back(y)
	select_mob.move(path)

