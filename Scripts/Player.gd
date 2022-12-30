extends CharacterBody2D

var move : Vector2 = Vector2(0, 0)
var grav_dir : int = 1
var state : String = "free_move" 
var crouching : bool = false
var latch_dir : String = "null"
var state_args = null
var holding_l_force : float = 0
var max_force : float = 1.0
var player_size : Vector2 = Vector2(10, 12)
var can_pogor : bool = true

var speed : float = 120
var grav : float = 300
var x_air_drag : float = 0.98
var y_air_drag : float = 0.98
var x_ground_drag : float = 0.8
var pogo_force_multiplier : float = 5
var highest : float = 10000000
var delta : float = 0.0

func _ready():
	Engine.time_scale = 0.5
	Global.Player = self
	reset()

func reset() -> void:
	$DownL.position = Vector2(-player_size.x + 1, player_size.y)
	$DownR.position = Vector2(player_size.x - 1, player_size.y)
	$UpL.position = Vector2(-player_size.x + 1, -player_size.y)
	$UpR.position = Vector2(player_size.x - 1, -player_size.y)
	$LeftU.position = Vector2(-player_size.x, -player_size.y + 1)
	$LeftD.position = Vector2(-player_size.x, player_size.y - 1)
	$RightU.position = Vector2(player_size.x, -player_size.y + 1)
	$RightD.position = Vector2(player_size.x, player_size.y - 1)

func calibrate_casts():
	if sign(move.y) == 1:
		$DownL.target_position.y = abs(move.y + 1) * grav_dir * delta
		$DownR.target_position.y = abs(move.y + 1) * grav_dir * delta
		$UpL.target_position.y = 0
		$UpR.target_position.y = 0
	elif sign(move.y) == -1:
		$UpL.target_position.y = -abs(move.y -1) * grav_dir * delta
		$UpR.target_position.y = -abs(move.y - 1) * grav_dir * delta
		$DownL.target_position.y = 0
		$DownR.target_position.y = 0
	else:
		$UpL.target_position.y = 0
		$UpR.target_position.y = 0
		$DownL.target_position.y = 0
		$DownR.target_position.y = 0
	
	$RightU.target_position.x = abs(move.x) * delta
	$RightD.target_position.x = abs(move.x) * delta
	$LeftU.target_position.x = -abs(move.x) * delta
	$LeftD.target_position.x = -abs(move.x) * delta
	$DownL.force_raycast_update()
	$DownR.force_raycast_update()
	$RightU.force_raycast_update()
	$RightD.force_raycast_update()
	$LeftU.force_raycast_update()
	$LeftD.force_raycast_update()
	$UpL.force_raycast_update()
	$UpR.force_raycast_update()
	

func _physics_process(del):
	delta = del
	calibrate_casts()
	#TO BE REMOVED VV
	if Input.is_action_just_pressed("esc"):
		get_tree().paused = true
	Global.Root.get_node("CanvasLayer/StateLabel").text = state

	pogo_input()
	
	
	
	if state == "free_move":
		move.x = (int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))) * speed
	else:
		pass
		#DADADADDADADAD
#		if on_floor():
#			move.x *= x_ground_drag
#		else:
#			move.x *= x_air_drag
	
	#need this code if pogo in mid air and detach so palyer starts falling
	if on_floor() && state == "free_move":
		move.y = 0
	
	if state in ["free_move", "flying"]:
		move.y += grav * grav_dir * delta
#		$Sprite2D.play("fall")
		down_collision()

	if state == "free_move":
		free_move()

	if state == "flying":
		flying()

	if state != "latching":
		$Pogo.look_at(get_global_mouse_position())
	
	if state == "latching":
		latching()

func power_charge() -> void:
	holding_l_force = min(global_position.distance_to(get_global_mouse_position()) / 100, max_force)
	$Pogo/Sprite2D.modulate = Color(1 - holding_l_force, 1 - holding_l_force, 1 - holding_l_force)
	$Pogo/Sprite2D.position.x = 32 - holding_l_force * 8

func trajectory() -> void:
	var trajecto_points = []
	var ang : float = rad_to_deg(global_position.angle_to_point(get_global_mouse_position()))
	if (latch_dir == "null") && ang > 0 && ang < 180 || latch_dir == "right" && ang > -90 && ang < 90 || latch_dir == "left" && (ang > -180 && ang < -90 || ang > 90 && ang < 180)  || latch_dir == "up" && (ang > -180 && ang < 0):
		if $Sprite2D.is_playing():
			$Sprite2D.stop()
		
		if on_floor():
			state = "crouching"
			$Sprite2D.rotation = 0
			$Sprite2D.animation = "crouch"
			#print(holding_l_force, " ", )
			$Sprite2D.frame = round(holding_l_force / (max_force / 3.0)) - 1
		
		#trajecto_points.append(Vector2(0, 0))
		var curr_pos = Vector2(0, 0)
		var curr_vel = (global_position - get_global_mouse_position()).normalized() * Vector2(holding_l_force * 50, holding_l_force * 40) * pogo_force_multiplier
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
				#inst.scale = Vector2((holding_l_force / max_force) * 2, (holding_l_force / max_force) * 2)
			else:
				$Trajecto.get_children()[i].global_position = trajecto_points[i] + $Trajecto.global_position
				#$Trajecto.get_children()[i].scale = Vector2((holding_l_force / max_force) * 2, (holding_l_force / max_force) * 2)
			current_ball_pos = trajecto_points[i]
				
	elif $Trajecto.get_child_count() != 0:
		for i in $Trajecto.get_children():
			i.queue_free()

func up_collision() -> void:
	if sign(move.y) == -1:
		if $UpL.get_collision_point().y - $UpL.global_position.y > move.y  && $UpL.is_colliding():
			global_position.y += $UpL.get_collision_point().y - $UpL.global_position.y
			obj_check("UpL")
		elif $UpR.get_collision_point().y - $UpR.global_position.y > move.y  && $UpR.is_colliding():
			global_position.y += $UpR.get_collision_point().y - $UpR.global_position.y
			obj_check("UpR")
		else:
			global_position.y += move.y

func down_collision() -> void:
	if sign(move.y) == 1:
		if abs($DownL.get_collision_point().y - $DownL.global_position.y) < abs(move.y * delta) && $DownL.is_colliding():
			global_position.y += $DownL.get_collision_point().y - $DownL.global_position.y
			move.y = 0
			obj_check("BotB")
			obj_check("DownL")
			state = "free_move"
		elif abs($DownR.get_collision_point().y - $DownR.global_position.y) < abs(move.y * delta)  && $DownR.is_colliding():
			global_position.y += $DownR.get_collision_point().y - $DownR.global_position.y
			move.y = 0
			obj_check("DownR")
			state = "free_move"
		else:
		#				$Sprite2D.play("fall")
			global_position.y += move.y * delta
			obj_check("DownL")
			obj_check("DownR")
			obj_check("BotB")
			
			
			
func right_collision() -> void:
	if abs($RightU.get_collision_point().x - ($RightU.global_position.x)) < move.x * delta  && $RightU.is_colliding():
			global_position.x += $RightU.get_collision_point().x - $RightU.global_position.x
			obj_check("RightU")
	elif abs($RightD.get_collision_point().x - $RightD.global_position.x) < move.x * delta  && $RightD.is_colliding():
		global_position.x += $RightD.get_collision_point().x - $RightD.global_position.x
		obj_check("RightD")
	else:
		global_position.x += move.x * delta
#				if $Sprite2D.animation != "run":
#					$Sprite2D.play("run")

func left_collision():
	if abs($LeftU.get_collision_point().x - $LeftU.global_position.x) < abs(move.x * delta) && $LeftU.is_colliding():
		global_position.x += $LeftU.get_collision_point().x - $LeftU.global_position.x
		obj_check("LeftU")
	elif abs($LeftD.get_collision_point().x - $LeftD.global_position.x) < abs(move.x * delta) && $LeftD.is_colliding():
		global_position.x += $LeftD.get_collision_point().x - $LeftD.global_position.x
		obj_check("LeftD")
	else:
		global_position.x += move.x * delta
#				if $Sprite2D.animation != "run":
#					$Sprite2D.play("run")


func latching() -> void:
	if latch_dir in ["left", "right"]:
		var ucast : RayCast2D = $LeftU if latch_dir == "left" else $RightU
		var dcast : RayCast2D = $LeftD if latch_dir == "left" else $RightD
		if Input.is_action_pressed("up"):
			move.y = -5
			up_collision()
		elif Input.is_action_pressed("down"):
			dcast.target_position = Vector2(5, 0)
			dcast.force_raycast_update()
			if ucast.is_colliding():
				move.y = 5
				down_collision()
			else:
				state = "free_move"
#	if sign(move.x) == 1:
#		right_collision()
#
#	elif sign(move.x) == -1:
#		left_collision()
#
#	if sign(move.y) == 1:
#		down_collision()
#	elif sign(move.y) == -1:
#		up_collision()
	
func free_move() -> void:
	if sign(move.x) == 1:
		$Sprite2D.rotation = deg_to_rad(8)
		if $Sprite2D.animation != "run":
			$Sprite2D.frame = 0
			$Sprite2D.play("run")
		$Sprite2D.scale.x = 1
		right_collision()

	elif sign(move.x) == -1:
		$Sprite2D.rotation = deg_to_rad(-8)
		if $Sprite2D.animation != "run":
			$Sprite2D.frame = 0
			$Sprite2D.play("run")
		$Sprite2D.scale.x = -1
		left_collision()
	else:
		$Sprite2D.rotation = deg_to_rad(0)
		if $Sprite2D.animation != "default":
			$Sprite2D.frame = 0
			$Sprite2D.play("default")

func flying() -> void:
	if $Sprite2D.animation != "spinny":
		$Sprite2D.play("spinny")
	#DADAD
	#move.y *= y_air_drag
	if sign(move.y) == -1:
		if $UpL.get_collision_point().y - $UpL.global_position.y > move.y * delta && $UpL.is_colliding():
			global_position.y += $UpL.get_collision_point().y - $UpL.global_position.y
			obj_check("UpL")
			pogocr("up")
		elif $UpR.get_collision_point().y - $UpR.global_position.y > move.y * delta && $UpR.is_colliding():
			global_position.y += $UpR.get_collision_point().y - $UpR.global_position.y
			obj_check("UpR")
			pogocr("up")
		else:
			global_position.y += move.y * delta
	
	if sign(move.x) == 1:
		if abs($RightU.get_collision_point().x - ($RightU.global_position.x)) < move.x * delta && $RightU.is_colliding():
			global_position.x += $RightU.get_collision_point().x - $RightU.global_position.x
			obj_check("RightU")
			pogocr("right")
		elif abs($RightD.get_collision_point().x - $RightD.global_position.x) < move.x * delta && $RightD.is_colliding():
			global_position.x += $RightD.get_collision_point().x - $RightD.global_position.x
			obj_check("RightD")
			pogocr("right")
		else:
			global_position.x += move.x * delta
#			if $Sprite2D.animation != "fall":
	
	elif sign(move.x) == -1:
		if abs($LeftU.get_collision_point().x - $LeftU.global_position.x) < abs(move.x * delta) && $LeftU.is_colliding():
			global_position.x += $LeftU.get_collision_point().x - $LeftU.global_position.x
			obj_check("LeftU")
			pogocr("left")
		elif abs($LeftD.get_collision_point().x - $LeftD.global_position.x) < abs(move.x * delta) && $LeftD.is_colliding():
			global_position.x += $LeftD.get_collision_point().x - $LeftD.global_position.x
			obj_check("LeftD")
			pogocr("left")
			
		else:
			global_position.x += move.x * delta
#				if $Sprite2D.animation != "fall":
#					$Sprite2D.play("fall")
	
	if sign(move.y) == 1:
		if $DownL.is_colliding() || $DownR.is_colliding():
			move = Vector2.ZERO
			state = "free_move"

func on_floor() -> bool:
	if $DownL.is_colliding():
		if $DownL.get_collision_point().distance_to($DownL.global_position) < 1:
			return true
	if $DownR.is_colliding():
		if $DownR.get_collision_point().distance_to($DownR.global_position) < 1:
			return true
			
	return false
			
func obj_check(dir) -> void:
	if dir == "BotB":
		if get_node("DownL").is_colliding() && get_node("DownR").is_colliding():
			if get_node("DownL").get_collider().has_method('is_GravUp') && get_node("DownR").get_collider().has_method('is_GravUp') && grav_dir == 1:
				grav_dir = -1
				$DownL.position = Vector2(-31, -32)
				$DownR.position = Vector2(31, -32)
				$UpL.position = Vector2(-31, 32)
				$UpR.position = Vector2(-31, 32)
				$Sprite2D.scale.y = -1
			
			if get_node("DownL").get_collider().has_method('is_GravDown') && get_node("DownR").get_collider().has_method('is_GravDown') && grav_dir == -1:
				grav_dir = 1
				$DownL.position = Vector2(-31, 32)
				$DownR.position = Vector2(31, 32)
				$UpL.position = Vector2(-31, -32)
				$UpR.position = Vector2(31, -32)
				$Sprite2D.scale.y = 1

func pogo_input() -> void:
	if !can_pogor && !$Pogo/PogoRay.is_colliding():
		can_pogor = true
	
	if Input.is_action_just_released("mb_right"):
		if state == "latching":
			if state_args != null:
				state_args.latched = null
				state_args = null
			state = "free_move"
			latch_dir = "null"
	
	if Input.is_action_pressed("mb_left"):
		if state == "free_move" && on_floor() || state in ["latching", "crouching"]:
			power_charge()
			trajectory()
	
	if Input.is_action_just_released("mb_left"):
		if state == "free_move" && on_floor() || state in ["latching", "crouching"]:
			#state = "free_move"
			pogol()
			holding_l_force = 0.2
			$Pogo/Sprite2D.modulate = Color(1, 1, 1)
			$Pogo/Sprite2D.position.x = 32 
			latch_dir = "null"
	
	if Input.is_action_just_pressed("down"):
		if state == "flying":
			Global.freeze(20)
			$DownL.target_position = Vector2(0, 5000)
			$DownR.target_position = Vector2(0, 5000)
			$DownL.force_raycast_update()
			$DownR.force_raycast_update()
			if $DownL.is_colliding():
				global_position += $DownL.get_collision_point() - $DownL.global_position
				state = "free_move"
			elif $DownR.is_colliding():
				global_position += $DownR.get_collision_point() - $DownR.global_position
				state = "free_move"
	

func pogol() -> void:
	$Sprite2D.play("default")
	for i in $Trajecto.get_children():
		i.queue_free()
	var ang : float= rad_to_deg(global_position.angle_to_point(get_global_mouse_position()))
	if (latch_dir == "null") && ang > 0 && ang < 180 || latch_dir == "right" && ang > -90 && ang < 90 || latch_dir == "left" && (ang > -180 && ang < -90 || ang > 90 && ang < 180)  || latch_dir == "up" && (ang > -180 && ang < 0):
		can_pogor = false
		state = "flying"
		move = (global_position - get_global_mouse_position()).normalized() * Vector2(holding_l_force * 50, holding_l_force * 40) * pogo_force_multiplier
		calibrate_casts()
		flying()
		#global_position += move
	else:
		state = "free_move"
#		if $Pogo/PogoRay.get_collider().has_method("is_enemy"):
#			if state_args != null:
#				state_args.latched = null
#				state_args = null
#			$Pogo/PogoRay.get_collider().die()
			

func pogocr(type : String) -> void:
	latch_dir = type
	if state != "latching":
		move = Vector2.ZERO
		state = "latching"
#			if $Pogo/PogoRay.get_collider().has_method("is_enemy"):
#				state_args = $Pogo/PogoRay.get_collider()
#				$Pogo/PogoRay.get_collider().latched = self

#func mouse_to_player():
	# # code to make mouse go to player when left clicked pressed. MAYBE MAKE AS OPTION ?
#	var s = DisplayServer.window_get_size()
#	var gc = get_global_transform_with_canvas().origin
#	if s.x / 512.0 >= s.y / 288.0:
#		var new_x = s.x / 2 - (512.0 * (s.y / 288.0)) / 2 + gc.x * (s.y / 288.0)
#		var new_y = s.y / 2 - (288.0 * (s.y / 288.0)) / 2 + gc.y * (s.y / 288.0)
#		Input.warp_mouse(Vector2(new_x, new_y))
#	else:
#		var new_x = s.x / 2 - (512.0 * (s.x / 512.0)) / 2 + gc.x * (s.x / 512.0)
#		var new_y = s.y / 2 - (288.0 * (s.x / 512.0)) / 2 + gc.y * (s.x / 512.0)
#		Input.warp_mouse(Vector2(new_x, new_y))
