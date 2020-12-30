extends Camera2D

var zoom_speed = 0.1
const MIN_ZOOM = 0.3
const MAX_ZOOM = 1.5
onready var LIMIT = get_node("../Map").position
var SIZE_MAP_X = 2500
var SIZE_MAP_Y = 1700

func _ready():
	if (Client.id_player == 0):
		position = Vector2(180, 180)
	else:
		position = Vector2(2100, 1450)

func _process(delta):
	var pos = get_global_mouse_position()
	if pos.x > LIMIT.x && pos.x < LIMIT.x + SIZE_MAP_X:
		position.x = pos.x
	if pos.y > LIMIT.y && pos.y < LIMIT.y + SIZE_MAP_Y:
		position.y = pos.y

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == BUTTON_WHEEL_DOWN:
			if zoom.x < MAX_ZOOM:
				zoom += Vector2(zoom_speed, zoom_speed)
		elif event.pressed && event.button_index == BUTTON_WHEEL_UP:
			if zoom.x > MIN_ZOOM:
				zoom -= Vector2(zoom_speed, zoom_speed)
