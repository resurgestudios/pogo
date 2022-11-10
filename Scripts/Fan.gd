tool
extends Area2D

export var strength : float = 1
export var length : float = 10
export var width : float = 10
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _physics_process(delta):
	if $BlowArea.get_overlapping_bodies().size() > 0:
		Global.Player.state = "flying"
		Global.Player.move += Vector2(0, -strength).rotated(rotation) * Vector2(strength, strength)# * Vector2(1 / (global_position.distance_to(Global.Player.global_position) / length), 1 / (global_position.distance_to(Global.Player.global_position) / length)) * Vector2(strength, strength)
	$WallCheck.cast_to = Vector2(0, -length * 2)
	if $WallCheck.is_colliding():
		$BlowArea.scale = Vector2(width, global_position.distance_to($WallCheck.get_collision_point()) / 4)
	else:
		$BlowArea.scale = Vector2(width, length)
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


