extends KinematicBody2D

var dir = 1
var latched = null
var move
var dead_state = false
var spawn_pos
var spawn_dir

func is_enemy():
	pass

func _ready():
	spawn_pos = position
	dir = sign(scale.x)
	spawn_dir = dir
	$Sprite.play("default")
	

func _physics_process(delta):
	if !dead_state:
		if !$RightDown.is_colliding() || $Right.is_colliding():
			dir *= -1
			scale.x *= -1
		
		move = Vector2(50 * dir, 20)
		
		if latched != null:
			if !(latched.get_node("LeftU").is_colliding() || latched.get_node("LeftD").is_colliding() || latched.get_node("RightU").is_colliding() || latched.get_node("RightD").is_colliding()):
				latched.move = move_and_slide(move, Vector2(0, -1)) / Vector2(60, 60)
		else:
			move_and_slide(move, Vector2(0, -1))


func _on_CollisionArea_body_entered(body):
	if body == Global.Player && !dead_state:
		pass
		#body.queue_free()

func die():
	$Sprite.stop()
	$Sprite.frame = 0
	$Sprite.visible = false
	
	position = spawn_pos
	scale.x = spawn_dir * 2
	dir = spawn_dir
	$Outline.visible = true
	dead_state = true
	$CollisionShape2D.disabled = true
	
