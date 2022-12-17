extends Node

var Root
var Player
var Camera

func instance_scene(path, parent, glo_pos):
	var inst = load(path).instantiate()
	parent.add_child(inst)
	inst.global_position = glo_pos
	return inst
