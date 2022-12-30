extends Node

var Root
var Player
var Camera
var gspeed : float = 1.0 : set = set_gspeed

func _ready():
	gspeed = gspeed

func instance_scene(path, parent, glo_pos) -> Node:
	var inst = load(path).instantiate()
	parent.add_child(inst)
	inst.global_position = glo_pos
	return inst

func freeze(duration : float) -> void:
#	Engine.time_scale = time_scale
#	await get_tree().create_timer(duration * time_scale).timeout
#	Engine.time_scale = 1.0
	OS.delay_msec(duration)

func set_gspeed(val):
	get_tree().call_group("slowmo_ani", "set_speed_scale", val)
