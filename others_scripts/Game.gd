extends Node

signal click_cell(pos)
var unit = preload("res://mob/Mob.tscn")
var select_mob

enum button {
	Left = 1,
	Right = 2,
	SpawnUnit = 3,
	UpgradeTown = 4,
	Market = 5,
	NextTurn = 6
}

func _ready():
	var id = 0
	for i in get_tree().get_nodes_in_group("spawn_button"):
		i.connect("pressed", self, "c_spawn_unit", [id])
		id += 1
	id = 0
	for i in get_tree().get_nodes_in_group("upgrade_town_button"):
		i.connect("pressed", self, "c_upgrade_town", [id])
		id += 1
	get_tree().get_nodes_in_group("next_turn")[0].connect("pressed", self, "c_next_turn")
	
	Client.connect("Market", self, "_market")
	Client.connect("SelectUnit", self, "_Select_Mob")
	Client.connect("SpawnUnit", self, "_spawn_unit")
	Client.connect("UpgradeTown", self, "_upgrade_town")
	Client.connect("nextTurn", self, "_next_turn")
	Client.connect("MoveUnit", self, "_move")
	Client.connect("Attack", self, "_attack")
	Client.connect("CaptureMine", self, "_capture_mine")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed && (event.button_index == BUTTON_LEFT || event.button_index == BUTTON_RIGHT):
			# crutch... so as not to click on the interface
			if event.position.x < get_node("/root/Game/interface/Control/Panel").get_position().x:
				if event.position.y > get_node("/root/Game/interface/Control/Panel2").get_size().y:
					var pos = get_node("Map").get_global_mouse_position() / 32
					pos = Vector2(int(pos.x) , int(pos.y))
					c_click_cell(event.button_index, pos)

# --------------------------- #

func c_click_cell(button, pos):
	print(pos)
	print(button)
	Client._action(button, pos, 0)
#	if select_mob:
#		if pos != select_mob.position_cell:
#			move(pos)

func c_spawn_unit(id):
	Client._action(button.SpawnUnit, Vector2.ZERO, id)

func c_upgrade_town(id):
	Client._action(button.UpgradeTown, Vector2.ZERO, 0)

func c_next_turn():
	Client._action(button.NextTurn, Vector2.ZERO, 0)

func c_market():
	Client._action(button.Market, Vector2.ZERO, 0)

# --------------------------- #

func _Select_Mob(pos):
	emit_signal("click_cell", pos)

func _spawn_unit(pos: Vector2, id):
	var u = unit.instance()
	print(pos)
	u.position = Vector2(pos.x * 32 + 16, pos.y * 32 + 16)
	u.name = "lol"
	get_node("Map").add_child(u)
	print("Spawn unit ", id)

func _upgrade_town(id):
	pass

func _market():
	pass

func _next_turn():
	pass

func _attack():
	pass

func _capture_mine(pos):
	print(pos)

func _move(path):
	select_mob.move(path)
	pass
#	print("Move to ", coord)
#	var path = []
#	var x
#	var y
#	var path_x = coord.x - select_mob.position_cell.x
#	var path_y = coord.y - select_mob.position_cell.y
#
#	if path_x < 0: 
#		x = 1
#		path_x *= -1
#	else: 
#		x = 0
#
#	if path_y < 0:
#		y = 3
#		path_y *= -1
#	else:
#		y = 2
#
#	for i in path_x:
#		path.push_back(x)
#	for i in path_y:
#		path.push_back(y)
#	select_mob.move(path)

# --------------------------- #
