extends KinematicBody2D

var dir = 1
var latched = null
var move

func is_enemy():
	pass

func _ready():
	dir = sign(scale.x)

func _physics_process(delta):
	if !$RightDown.is_colliding() || $Right.is_colliding():
		dir *= -1
		scale.x *= -1
	
	move = Vector2(50 * dir, 20)
	
	if latched != null:
		latched.move = move_and_slide(move, Vector2(0, -1)) / Vector2(60, 60)
	else:
		move_and_slide(move, Vector2(0, -1))


func _on_CollisionArea_body_entered(body):
	if body == Global.Player:
		pass
		#body.queue_free()
