extends KinematicBody2D

var move = Vector2(0, 0)
var grav_dir = 1
var state = "free_move" 
var state_args = null
var holding_l = false
var holding_l_force = 0
var player_size = Vector2(25, 27)
var can_pogor = true

var speed = 5
var grav = 1
var x_air_drag = 0.98
var y_air_drag = 0.98
var x_ground_drag = 0.8
var bounciness = 0.8
var pogo_force_multiplier = 1.0
var highest = 10000000

func _ready():
	Global.Player = self
	reset()

func reset():
	$DownL.position = Vector2(-player_size.x + 1, player_size.y)
	$DownR.position = Vector2(player_size.x - 1, player_size.y)
	$UpL.position = Vector2(-player_size.x + 1, -player_size.y)
	$UpR.position = Vector2(player_size.x - 1, -player_size.y)
	$LeftU.position = Vector2(-player_size.x, -player_size.y + 1)
	$LeftD.position = Vector2(-player_size.x, player_size.y - 1)
	$RightU.position = Vector2(player_size.x, -player_size.y + 1)
	$RightD.position = Vector2(player_size.x, player_size.y - 1)

func _physics_process(delta):
	if Input.is_action_just_pressed("esc"):
		get_tree().paused = true
	Global.Root.get_node("CanvasLayer/StateLabel").text = state
	
	pogo_input()
	
	if holding_l:
		power_charge()
		trajectory()
	
	if sign(move.y) == 1:
		$DownL.cast_to.y = abs(move.y + 1) * grav_dir
		$DownR.cast_to.y = abs(move.y + 1) * grav_dir
		$UpL.cast_to.y = 0
		$UpR.cast_to.y = 0
	elif sign(move.y) == -1:
		$UpL.cast_to.y = -abs(move.y -1) * grav_dir
		$UpR.cast_to.y = -abs(move.y - 1) * grav_dir
		$DownL.cast_to.y = 0
		$DownR.cast_to.y = 0
	else:
		$UpL.cast_to.y = 0
		$UpR.cast_to.y = 0
		$DownL.cast_to.y = 0
		$DownR.cast_to.y = 0


	$RightU.cast_to.x = abs(move.x)
	$RightD.cast_to.x = abs(move.x)
	$LeftU.cast_to.x = -abs(move.x)
	$LeftD.cast_to.x = -abs(move.x)
	$DownL.force_raycast_update()
	$DownR.force_raycast_update()
	$RightU.force_raycast_update()
	$RightD.force_raycast_update()
	$LeftU.force_raycast_update()
	$LeftD.force_raycast_update()
	$UpL.force_raycast_update()
	$UpR.force_raycast_update()
	
	
	if state == "free_move":
		move.x = (int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))) * speed
	else:
		if on_floor():
			move.x *= x_ground_drag
		else:
			move.x *= x_air_drag
	
	#need this code if pogo in mid air and detach so palyer starts falling
	if on_floor() && state == "free_move":
		move.y = 0
	
	if state in ["free_move", "flying"]:
		move.y += grav * grav_dir
#		$Sprite.play("fall")

	down_collision()

	if state == "free_move":
		free_move()

	if state == "flying":
		flying()

	if state != "latching":
		$Pogo.look_at(get_global_mouse_position())
	
	if state == "latching":
		latching()

func power_charge():
	holding_l_force = min(holding_l_force + 0.02, 1)
	$Pogo/Sprite.modulate = Color(1 - holding_l_force, 1 - holding_l_force, 1 - holding_l_force)
	$Pogo/Sprite.position.x = 32 - holding_l_force * 8

func trajectory():
	var trajecto_points = []
	if $Pogo/PogoRay.is_colliding():
		#trajecto_points.append(Vector2(0, 0))
		var curr_pos = Vector2(0, 0)
		var curr_vel = (global_position - $Pogo/PogoRay.get_collision_point()).normalized() * Vector2(holding_l_force * 50, holding_l_force * 40) * pogo_force_multiplier
		$Trajecto.position = curr_pos
		for i in range(0, 15):
			curr_pos += curr_vel
			curr_vel.x *= x_air_drag
			curr_vel.y += grav * grav_dir
			curr_vel.y *= y_air_drag
			trajecto_points.append(curr_pos)
		
		
		#maybe one day make balls equally spaced
		var current_ball_pos = trajecto_points[0]
		for i in range(0, trajecto_points.size()):
			if i > $Trajecto.get_child_count() - 1:
				var inst = Global.instance_scene("res://Scenes/TrajectoBall.tscn", $Trajecto, trajecto_points[i] + $Trajecto.global_position)
			else:
				$Trajecto.get_children()[i].global_position = trajecto_points[i] + $Trajecto.global_position
			current_ball_pos = trajecto_points[i]
				
	elif $Trajecto.get_child_count() != 0:
		for i in $Trajecto.get_children():
			i.queue_free()

func up_collision():
	if sign(move.y) == -1:
		if $UpL.get_collision_point().y - $UpL.global_position.y > move.y  && $UpL.is_colliding():
			move.y *= -bounciness
			global_position.y += $UpL.get_collision_point().y - $UpL.global_position.y
			obj_check("UpL")
		elif $UpR.get_collision_point().y - $UpR.global_position.y > move.y  && $UpR.is_colliding():
			move.y *= -bounciness
			global_position.y += $UpR.get_collision_point().y - $UpR.global_position.y
			obj_check("UpR")
		else:
			global_position.y += move.y

func down_collision():
	if sign(move.y) == 1:
		if abs($DownL.get_collision_point().y - $DownL.global_position.y) < abs(move.y) && $DownL.is_colliding():
			global_position.y += $DownL.get_collision_point().y - $DownL.global_position.y
			if abs($DownR.get_collision_point().y - $DownR.global_position.y) < abs(move.y) && $DownR.is_colliding():
				obj_check("BotB")
			move.y = 0 if state == "free_move" else move.y * -bounciness
			obj_check("DownL")
		elif abs($DownR.get_collision_point().y - $DownR.global_position.y) < abs(move.y)  && $DownR.is_colliding():
			global_position.y += $DownR.get_collision_point().y - $DownR.global_position.y
			move.y = 0 if state == "free_move" else move.y * -bounciness
			obj_check("DownR")
		else:
		#				$Sprite.play("fall")
			global_position.y += move.y
			obj_check("DownL")
			obj_check("DownR")
			obj_check("BotB")
			
			
func right_collision():
	if abs($RightU.get_collision_point().x - ($RightU.global_position.x)) < move.x  && $RightU.is_colliding():
			global_position.x += $RightU.get_collision_point().x - $RightU.global_position.x
			obj_check("RightU")
	elif abs($RightD.get_collision_point().x - $RightD.global_position.x) < move.x  && $RightD.is_colliding():
		global_position.x += $RightD.get_collision_point().x - $RightD.global_position.x
		obj_check("RightD")
	else:
		global_position.x += move.x
#				if $Sprite.animation != "run":
#					$Sprite.play("run")

func left_collision():
	if abs($LeftU.get_collision_point().x - $LeftU.global_position.x) < abs(move.x) && $LeftU.is_colliding():
		global_position.x += $LeftU.get_collision_point().x - $LeftU.global_position.x
		obj_check("LeftU")
	elif abs($LeftD.get_collision_point().x - $LeftD.global_position.x) < abs(move.x) && $LeftD.is_colliding():
		global_position.x += $LeftD.get_collision_point().x - $LeftD.global_position.x
		obj_check("LeftD")
	else:
		global_position.x += move.x
#				if $Sprite.animation != "run":
#					$Sprite.play("run")


func latching():
	if sign(move.x) == 1:
		right_collision()

	elif sign(move.x) == -1:
		left_collision()
		
	if sign(move.y) == 1:
		down_collision()
	elif sign(move.y) == -1:
		up_collision()
	
func free_move():
	if sign(move.x) == 1:
		$Sprite.scale.x = 2
		right_collision()

	elif sign(move.x) == -1:
		$Sprite.scale.x = -2
		left_collision()

func flying():
	move.y *= y_air_drag
	if sign(move.y) == -1:
		if $UpL.get_collision_point().y - $UpL.global_position.y > move.y  && $UpL.is_colliding():
			move.y *= -bounciness
			global_position.y += $UpL.get_collision_point().y - $UpL.global_position.y
			obj_check("UpL")
		elif $UpR.get_collision_point().y - $UpR.global_position.y > move.y  && $UpR.is_colliding():
			move.y *= -bounciness
			global_position.y += $UpR.get_collision_point().y - $UpR.global_position.y
			obj_check("UpR")
		else:
			global_position.y += move.y
	
	if sign(move.x) == 1:
		if abs($RightU.get_collision_point().x - ($RightU.global_position.x)) < move.x  && $RightU.is_colliding():
			global_position.x += $RightU.get_collision_point().x - $RightU.global_position.x
			obj_check("RightU")
			move.x *= -bounciness
		elif abs($RightD.get_collision_point().x - $RightD.global_position.x) < move.x  && $RightD.is_colliding():
			global_position.x += $RightD.get_collision_point().x - $RightD.global_position.x
			move.x *= -bounciness
			obj_check("RightD")
		else:
			global_position.x += move.x
#			if $Sprite.animation != "fall":
	
	elif sign(move.x) == -1:
		if abs($LeftU.get_collision_point().x - $LeftU.global_position.x) < abs(move.x) && $LeftU.is_colliding():
			global_position.x += $LeftU.get_collision_point().x - $LeftU.global_position.x
			move.x *= -bounciness
			obj_check("LeftU")
		elif abs($LeftD.get_collision_point().x - $LeftD.global_position.x) < abs(move.x) && $LeftD.is_colliding():
			global_position.x += $LeftD.get_collision_point().x - $LeftD.global_position.x
			move.x *= -bounciness
			obj_check("LeftD")
		else:
			global_position.x += move.x
#				if $Sprite.animation != "fall":
#					$Sprite.play("fall")
	
	if abs(round(move.x)) <= 6 && abs(round(move.y)) <= 6:
		if $DownL.is_colliding() || $DownR.is_colliding():
			print("DOPA")
			move = Vector2.ZERO
			state = "free_move"

func on_floor():
	if $DownL.is_colliding():
		if $DownL.get_collision_point().distance_to($DownL.global_position) < 1:
			return true
	if $DownR.is_colliding():
		if $DownR.get_collision_point().distance_to($DownR.global_position) < 1:
			return true
			
func obj_check(dir):
	if dir == "BotB":
		if get_node("DownL").is_colliding() && get_node("DownR").is_colliding():
			if get_node("DownL").get_collider().has_method('is_GravUp') && get_node("DownR").get_collider().has_method('is_GravUp') && grav_dir == 1:
					grav_dir = -1
					$DownL.position = Vector2(-31, -32)
					$DownR.position = Vector2(31, -32)
					$UpL.position = Vector2(-31, 32)
					$UpR.position = Vector2(-31, 32)
					$Sprite.scale.y = -1
			
			if get_node("DownL").get_collider().has_method('is_GravDown') && get_node("DownR").get_collider().has_method('is_GravDown') && grav_dir == -1:
					grav_dir = 1
					$DownL.position = Vector2(-31, 32)
					$DownR.position = Vector2(31, 32)
					$UpL.position = Vector2(-31, -32)
					$UpR.position = Vector2(31, -32)
					$Sprite.scale.y = 1

func pogo_input():
	
	if !can_pogor && !$Pogo/PogoRay.is_colliding():
		can_pogor = true
	
	if Input.is_action_just_released("mb_right"):
		if state == "latching":
			if state_args != null:
				state_args.latched = null
				state_args = null
			print("DDD")
			state = "free_move"
			
	if Input.is_action_pressed("mb_right"):
		if state != "latching":
			pogor()
	
	if Input.is_action_just_pressed("mb_left"):
		holding_l = true
	
	if Input.is_action_just_released("mb_left"):
		pogol()
		holding_l = false
		holding_l_force = 0.2
		$Pogo/Sprite.modulate = Color(1, 1, 1)
		$Pogo/Sprite.position.x = 32 
	

func pogol():
	for i in $Trajecto.get_children():
		i.queue_free()
	if $Pogo/PogoRay.is_colliding():
		can_pogor = false
		state = "flying"
		move = (global_position - $Pogo/PogoRay.get_collision_point()).normalized() * Vector2(holding_l_force * 50, holding_l_force * 40) * pogo_force_multiplier
		#global_position += move
		
		if $Pogo/PogoRay.get_collider().has_method("is_enemy"):
			if state_args != null:
				state_args.latched = null
				state_args = null
			$Pogo/PogoRay.get_collider().die()
			
			
	
func pogor():
	if $Pogo/PogoRay.is_colliding() && can_pogor:
		move = Vector2.ZERO
		state = "latching"
		if $Pogo/PogoRay.get_collider().has_method("is_enemy"):
			state_args = $Pogo/PogoRay.get_collider()
			$Pogo/PogoRay.get_collider().latched = self
