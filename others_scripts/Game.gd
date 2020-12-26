extends Node

signal click_cell(pos)
signal move_unit(pos, path)
var unit = preload("res://mob/Mob.tscn")
var my_unit: Node
var select_mob: Node

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
	Client.connect("NextTurn", self, "_next_turn")
	Client.connect("MoveUnit", self, "_move")
	Client.connect("Attack", self, "_attack")
	Client.connect("CaptureMine", self, "_capture_mine")

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
#	if select_mob:
#		if !select_mob.path.empty():
#			print("NO!")
#			return
	Client._action(button, pos, 0)

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
	my_unit = select_mob

func _spawn_unit(pos: Vector2, id):
	var u = unit.instance()
	print(pos)
	u.position = Vector2(pos.x * 32 + 16, pos.y * 32 + 16)
	u.name = "lol"
	$interface/Control/Panel2/Gold.text = "123"
	get_node("Map").add_child(u)
	print("Spawn unit ", id)

func _upgrade_town(level, health):
	print("town: ", level, " - ", health)

func _market():
	pass

func _attack(d2, pos):
	print("!!!!!!!!!!!!!!!!!!!!!!")
	print(d2)
	print(pos)
	if (d2 == 0):
		emit_signal("click_cell", pos)
		get_node("Map").remove_child(select_mob)

func _capture_mine(pos):
	print("Mine: ", pos)

func _move(pos, path):
	my_unit.move(pos, path)

# --------------------------- #
