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
	Client.connect("UpdateResources", self, "update_resources")

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed && (event.button_index == BUTTON_LEFT || event.button_index == BUTTON_RIGHT):
			# crutch... so as not to click on the interface
			if event.position.x < get_node("/root/Game/interface/Control/Panel").get_position().x:
				if event.position.y > get_node("/root/Game/interface/Control/Panel2").get_size().y:
					var pos = get_node("Map").get_global_mouse_position() / 32
					var a = 0
					var b = 0
					if (int(pos.x)==0):
						a-=1
					if (int(pos.y)==0):
						b-=1
					pos = Vector2(int(pos.x+a) , int(pos.y+b))
					c_click_cell(event.button_index, pos)

# --------------------------- #

func c_click_cell(button, pos):
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
	$interface/Control/Panel/Panel/attack.text = String(my_unit.attack)
	$interface/Control/Panel/Panel/defense.text = String(my_unit.defense)
	$interface/Control/Panel/Panel/damage.text = String(my_unit.damage)
	$interface/Control/Panel/Panel/health.text = String(my_unit.health)
	$interface/Control/Panel/Panel/actionPoints.text = String(my_unit.actionPoints)
	$interface/Control/Panel/Panel/rangeAttack.text = String(my_unit.rangeAttack)
	$interface/Control/Panel/Panel/shootingDamage.text = String(my_unit.shootingDamage)

func _spawn_unit(pos: Vector2, id, attack, defense, damage, health, actionPoints, rangeAttack, shootingDamage):
	var u = unit.instance()
	u.position = Vector2(pos.x * 32 + 16, pos.y * 32 + 16)
	u.attack = attack
	u.defense = defense
	u.damage = damage
	u.health = health
	u.actionPoints = actionPoints
	u.rangeAttack = rangeAttack
	u.shootingDamage = shootingDamage
	u._initiz(id)
	get_node("Map").add_child(u)
	print("Spawn unit ", id)

func _upgrade_town(level, health):
	print("town: ", level, " - ", health)

func _market():
	pass

func _attack(d2, pos):
	print("hp vrag: ", d2)
	if (d2 == 0):
		emit_signal("click_cell", pos)
		get_node("Map").remove_child(select_mob)

func _capture_mine(pos):
	print("Mine: ", pos)

func _move(pos, path, actionPoints):
	my_unit.actionPoints = actionPoints
	$interface/Control/Panel/Panel/actionPoints.text = String(my_unit.actionPoints)
	my_unit.move(pos, path)

func update_resources(Gold, Wood, Rock, Crystall):
	$interface/Control/Panel2/Gold.text = String(Gold)
	$interface/Control/Panel2/Wood.text = String(Wood)
	$interface/Control/Panel2/Rock.text = String(Rock)
	$interface/Control/Panel2/Crystal.text = String(Crystall)
# --------------------------- #
