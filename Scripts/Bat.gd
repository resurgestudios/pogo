extends CharacterBody2D

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
	
func is_bat():
	pass

func _ready():
	spawn_pos = position
	$Sprite2D.play("default")
	

func _physics_process(delta):
	if !dead_state:
		if active:
			move += (Global.Player.global_position - global_position).normalized() * Vector2(0.4, 0.4)
			move = move.clamp(10)
			move += Vector2(rng.randf_range(-0.2, 0.2), rng.randf_range(-0.2, 0.2))
		else:
			move *= Vector2(0.2, 0.2)
		
		var col = move_and_collide(move)
		if col:
			move = move.bounce(col.normal)
		if latched != null:
			latched.move = move

func _on_CollisionArea_body_entered(body):
	if body == Global.Player && !dead_state:
		pass
		#body.queue_free()

func die():
	$Sprite2D.stop()
	$Sprite2D.frame = 0
	$Sprite2D.visible = false
	
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
		$Sprite2D.play("default")
		$Sprite2D.visible = true
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
