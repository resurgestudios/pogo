extends Node2D

var playing = true
var chunk_number = 1
var next_chunk_y = 1088
var rng = RandomNumberGenerator.new()
var scene_count = 2

var death_range = 300 #how many pixels from highest place before death

func _ready():
	Global.Root = self
	rng.randomize()
	$Terrain/Floor.tile_setup()


func _physics_process(delta):
	$Walls.global_position.y = Global.Player.global_position.y - 300
	if $Player.global_position.y < $Player.highest:
		$Player.highest = $Player.global_position.y
	elif $Player.global_position.y > $Player.highest + death_range * 10 && playing:
		$Walls/AnimationPlayer.play("Death")
		playing = false
	
	chunk_generation()

func chunk_generation():
	#print($Player.position, next_chunk_y)
	if $Player.position.y < next_chunk_y + 1080 * 2:
		rng.randomize()
		var inst = load("res://Scenes/Chunks/1/" + str(rng.randi_range(1, scene_count)) + ".tscn").instance()
		$Terrain.add_child(inst)
		inst.global_position.y = next_chunk_y
		inst.tile_setup()
		next_chunk_y -= inst.highest - inst.lowest
		
		if abs($Player.position.y - $Terrain.get_children()[0].position.y) > 6000:
			$Terrain.get_children()[0].queue_free()
		chunk_number += 1
		inst.name = str(chunk_number)
