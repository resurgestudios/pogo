extends Node

var Root
var Player

func instance_scene(path, parent, glo_pos):
	var inst = load(path).instance()
	parent.add_child(inst)
	inst.global_position = glo_pos
	return inst
