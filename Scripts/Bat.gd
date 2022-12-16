extends KinematicBody2D

var latched = null
var move = Vector2(0, 0)
var dead_state = false
var active = false

var spawn_pos
var spawn_dir
var spawn_time = 5
var spawn_stage = 0
var rng = RandomNumberGenerator.new()

func is_enemy():
	pass

func _ready():
	spawn_pos = position
	$Sprite.play("default")
	

func _physics_process(delta):
	if !dead_state:
		if active:
			move += (Global.Player.global_position - global_position).normalized() * Vector2(0.4, 0.4)
			move = move.clamped(10)
			move += Vector2(rng.randf_range(-0.2, 0.2), rng.randf_range(-0.2, 0.2))
		else:
			move *= Vector2(0.2, 0.2)
		
		
		if latched != null:
			if !(latched.get_node("LeftU").is_colliding() || latched.get_node("LeftD").is_colliding() || latched.get_node("RightU").is_colliding() || latched.get_node("RightD").is_colliding() || latched.get_node("UpL").is_colliding() || latched.get_node("UpR").is_colliding() || latched.get_node("DownL").is_colliding() || latched.get_node("DownR").is_colliding()):
				latched.move = move
				var col = move_and_collide(move)
				if col:
					move = move.bounce(col.normal)
			else:
				if (latched.get_node("LeftU").is_colliding() || latched.get_node("LeftD").is_colliding()) && sign(move.x) == -1:
					move.x *= -1
				elif (latched.get_node("RightU").is_colliding() || latched.get_node("RightD").is_colliding()) && sign(move.x) == 1:
					move.x *= -1
				
				if (latched.get_node("UpL").is_colliding() || latched.get_node("UpR").is_colliding()) && sign(move.y) == -1:
					move.y *= -1
				elif (latched.get_node("DownL").is_colliding() || latched.get_node("DownR").is_colliding()) && sign(move.y) == 1:
					move.y *= -1
				var col = move_and_collide(move)
				if col:
					move = move.bounce(col.normal)
				latched.move = move
		else:
			var col = move_and_collide(move)
			if col:
				move = move.bounce(col.normal)


func _on_CollisionArea_body_entered(body):
	if body == Global.Player && !dead_state:
		pass
		#body.queue_free()

func die():
	$Sprite.stop()
	$Sprite.frame = 0
	$Sprite.visible = false
	
	position = spawn_pos
	$Outline.visible = true
	dead_state = true
	$CollisionShape2D.disabled = true
	$Outline/SpawnTimer.start(spawn_time - 2)


func _on_SpawnTimer_timeout():
	$Outline.modulate = Color8(255, 0, 0)
	if spawn_stage in [0, 1, 2, 3, 4]:
		$Outline.visible = !$Outline.visible
		spawn_stage += 1
		$Outline/SpawnTimer.start(0.5)
		
	elif spawn_stage == 5:
		$Sprite.play("default")
		$Sprite.visible = true
		$Outline.visible = false
		dead_state = false
		$CollisionShape2D.disabled = false
		spawn_stage = 0
		$Outline.modulate = Color8(255, 255, 255)


func _on_VisionArea_body_entered(body):
	print(body)
	if body == Global.Player:
		
		active = true


func _on_VisionArea_body_exited(body):
	if body == Global.Player:
		active = false
