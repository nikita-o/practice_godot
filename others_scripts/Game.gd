extends Node

signal click_cell(pos)
var unit = preload("res://mob/Mob.tscn")
var my_unit: Node
var select_mob: Node

enum button {
	Left = 1,
	Right = 2,
	SpawnUnit = 3,
	UpgradeTown = 4,
	Market = 5,
	NextTurn = 6,
	Cheats = 7,
	Give_up = 8,
}

func _ready():
	var id = 0
	for i in get_tree().get_nodes_in_group("spawn_button"):
		i.connect("pressed", self, "c_spawn_unit", [id])
		id += 1
	get_tree().get_nodes_in_group("upgrade_town_button")[0].connect("pressed", self, "c_upgrade_town")
	get_tree().get_nodes_in_group("next_turn")[0].connect("pressed", self, "c_next_turn")
	$interface/Control/Panel2/Menu.connect("pressed", self, "c_pause")
	var _error
	_error = Client.connect("Market", self, "_market")
	_error = Client.connect("SelectUnit", self, "_Select_Mob")
	_error = Client.connect("SpawnUnit", self, "_spawn_unit")
	_error = Client.connect("UpgradeTown", self, "_upgrade_town")
	_error = Client.connect("MoveUnit", self, "_move")
	_error = Client.connect("Attack", self, "_attack")
	_error = Client.connect("CaptureMine", self, "_capture_mine")
	_error = Client.connect("UpdateResources", self, "update_resources")
	_error = Client.connect("AttackTown", self, "attack_town")
	_error = Client.connect("Error_print", self, "print_error")

func c_pause():
	$pause/Control.visible = true

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed && (event.button_index == BUTTON_LEFT || event.button_index == BUTTON_RIGHT) && !$pause/Control.visible:
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

func c_upgrade_town():
	Client._action(button.UpgradeTown, Vector2.ZERO, 0)

func c_next_turn():
	Client._action(button.NextTurn, Vector2.ZERO, 0)

func c_market():
	Client._action(button.Market, Vector2.ZERO, 0)

func c_cheats():
	Client._action(button.Cheats, Vector2.ZERO, 0)

func c_give_up():
	Client._action(button.Give_up, Vector2.ZERO, 0)

# --------------------------- #

func _Select_Mob(pos, action_points):
	print("\tSelectUnit: ", pos)
	emit_signal("click_cell", pos)
	if my_unit != null:
		my_unit.get_node("Sprite").visible = false
	my_unit = select_mob
	my_unit.get_node("Sprite").visible = true
	my_unit.actionPoints = action_points
	$interface/Control/Panel/Panel/attack.text = String(my_unit.attack)
	$interface/Control/Panel/Panel/defense.text = String(my_unit.defense)
	$interface/Control/Panel/Panel/damage.text = String(my_unit.damage)
	$interface/Control/Panel/Panel/health.text = String(my_unit.health)
	$interface/Control/Panel/Panel/actionPoints.text = String(my_unit.actionPoints)
	$interface/Control/Panel/Panel/rangeAttack.text = String(my_unit.rangeAttack)
	$interface/Control/Panel/Panel/shootingDamage.text = String(my_unit.shootingDamage)

func _spawn_unit(enemy, pos: Vector2, id, attack, defense, damage, health, actionPoints, rangeAttack, shootingDamage):
	var u = unit.instance()
	u.position = Vector2(pos.x * 32 + 16, pos.y * 32 + 16)
	u.attack = attack
	u.defense = defense
	u.damage = damage
	u.health = health
	u.actionPoints = actionPoints
	u.rangeAttack = rangeAttack
	u.shootingDamage = shootingDamage
	u.get_node("Label").text = String(u.health)
	if enemy: u.get_node("Label").modulate = Color(0,0,255)
	else: u.get_node("Label").modulate = Color(255,0,0)
	u._initiz(id)
	get_node("Map").add_child(u)
	print("\tSpawn unit ", id)

func _upgrade_town(level, health):
	print("\tupgrade town! lvl = ", level, ", health = ", health)

func _market():
	pass

func _attack(defens_health, defens_position):
	print("\tAttack: ", defens_position)
	print("\thp enemy: ", defens_health)
	emit_signal("click_cell", defens_position)
	my_unit.actionPoints = 0
	$interface/Control/Panel/Panel/actionPoints.text = String(my_unit.actionPoints)
	select_mob.health = defens_health
	select_mob.get_node("Label").text = String(select_mob.health)
	if (defens_health <= 0):
		get_node("Map").remove_child(select_mob)

func attack_town(health_town):
	print("\tTown hp = ", health_town)

func _capture_mine(pos, enemy):
	print("\tcapture mine: ", pos)
	emit_signal("click_cell", pos)
	select_mob.capture_mine(enemy)

func _move(end_pos, path, actionPoints, start_pos):
	print("\tMoveUnit")
	emit_signal("click_cell", start_pos)
	select_mob.actionPoints = actionPoints
	$interface/Control/Panel/Panel/actionPoints.text = String(select_mob.actionPoints)
	select_mob.move(end_pos, path)

func update_resources(Gold, Wood, Rock, Crystall):
	print("\tupdate resources")
	$interface/Control/Panel2/Gold.text = String(Gold)
	$interface/Control/Panel2/Wood.text = String(Wood)
	$interface/Control/Panel2/Rock.text = String(Rock)
	$interface/Control/Panel2/Crystal.text = String(Crystall)
# --------------------------- #

func print_error(_text):
	$interface/Control/Error.text = _text
	$interface/Control/Error.visible = true
	yield(get_tree().create_timer(5.0), "timeout")
	$interface/Control/Error.visible = false
