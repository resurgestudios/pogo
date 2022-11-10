extends Node

var Root
var Player

func instance_scene(path, parent, glob_pos):
	var inst = load(path).instance()
	parent.add_child(inst)
	inst.global_position = glob_pos
	return inst
