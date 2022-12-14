extends CharacterBody2D

var dir = 1
var latched = null
var move
var dead_state = false

var spawn_pos
var spawn_dir
var spawn_time = 5
var spawn_stage = 0

func is_enemy():
	pass
	
func is_spikey():
	pass

func _ready():
	spawn_pos = position
	dir = sign(scale.x)
	spawn_dir = dir
	$Sprite2D.play("default")
	

func _physics_process(delta):
	if !dead_state:
		if !$Rays/RightDown.is_colliding() || $Rays/Right.is_colliding():
			dir *= -1
			$Sprite2D.scale.x *= -1
			$Outline.scale.x *= -1
			$Rays.scale.x *= -1
		
		move = Vector2(50 * dir, 20)
		
		set_velocity(move * Global.gspeed)
		set_up_direction(Vector2(0, -1))
		move_and_slide()


func _on_CollisionArea_body_entered(body):
	if body == Global.Player && !dead_state:
		pass
		#body.queue_free()

func die():
	$Sprite2D.stop()
	$Sprite2D.frame = 0
	$Sprite2D.visible = false
	
	position = spawn_pos
	$Sprite2D.scale.x = spawn_dir
	$Outline.scale.x = spawn_dir
	$Rays.scale.x = spawn_dir
	dir = spawn_dir
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
