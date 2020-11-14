extends Node

signal select_unit

var select_mob

# Called when the node enters the scene tree for the first time.
func _ready():
	var id = 0
	for i in get_tree().get_nodes_in_group("spawn_button"):
		i.connect("pressed", self, "spawn_unit", [id])
		id += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if select_mob:
		if event is InputEventMouseButton:
			if event.pressed && event.button_index == BUTTON_LEFT:
				var Mouse_pos = get_node("Map").get_global_mouse_position() / 32
				Mouse_pos = Vector2(int(Mouse_pos.x) , int(Mouse_pos.y))
				print(Mouse_pos)

func spawn_unit(id, count = 1):
	print(id)
