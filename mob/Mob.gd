extends Area2D

const speed = 1
const step = 32 / speed

var position_cell
var path: Array

var Animate:AnimatedSprite

var my_owner: int

var type_unit
var attack
var defense
var damage
var health
var actionPoints
var rangeAttack
var shootingDamage

func _initiz(id):
	match id:
		0: 
			Animate = $Scout
		1: 
			Animate = $Warrior1
		2: 
			Animate = $Shooter1
		3: 
			Animate = $Warrior2
		4: 
			Animate = $Shooter2
		5: 
			Animate = $Warrior3
		6: 
			Animate = $Shooter3
		7: 
			Animate = $Top_unit
	$Mine.visible = false
	$Label.visible = true
	Animate.visible = true
	Animate.play("default")
	$Mine.color = Color(0,0,1,0.3)

func _ready():
	position_cell = Vector2(int(position.x / 32), int(position.y / 32))
	self.connect("select_mob", get_node("/root/Game"), "_Select_Mob", [self])
	get_node("/root/Game").connect("click_cell", self, "_click_cell")
	set_process(false)

var p = step
var s
func _process(delta):
	if p < step:
		p += 1
	else:
		if path.empty():
			Animate.play("default")
			set_process(false)
			return
		s = path.pop_front()
		p = 0
		return
	
	match s:
			1: 
				Animate.flip_h = true
				position += Vector2(-speed, -speed)	# left up
			2: 
				position += Vector2(0, -speed) 		# up
			3: 
				Animate.flip_h = false
				position += Vector2(speed, -speed) 	# right up
			4: 
				Animate.flip_h = false
				position += Vector2(speed, 0) 		# right
			5: 
				Animate.flip_h = false
				position += Vector2(speed, speed) 	# right down
			6: 
				position += Vector2(0, speed) 		# down
			7: 
				Animate.flip_h = true
				position += Vector2(-speed, speed) 	# left down
			8:
				Animate.flip_h = true
				position += Vector2(-speed, 0) 		# left 

func _click_cell(pos):
	if pos == position_cell:
		get_node("/root/Game").select_mob = self

func die():
	Animate.play("die")	
	pass

func attack():
	Animate.play("attack")
	yield(get_tree().create_timer(2.5), "timeout")
	Animate.play("default")
	pass

func hurt():
	Animate.play("hurt")
	yield(get_tree().create_timer(2.5), "timeout")
	Animate.play("default")
	pass

func move(pos, _path):
	position_cell = pos
	self.path += _path
	Animate.play("walk")
	set_process(true)

func capture_mine(enemy):
	if enemy: $Mine.color = Color(255,0,0)
	else: $Mine.color = Color(0,255,0)
