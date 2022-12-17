extends Area2D

@export var strength : float = 1

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Cannon_body_entered(body):
	if body == Global.Player:
		body.state = "frozen"
		body.move = Vector2(0, 0)
		body.global_position = global_position
		$Timer.start(1)


func _on_Timer_timeout():
	Global.Player.state = "flying"
	Global.Player.move =  Vector2(0, -50).rotated(rotation) * Vector2(strength, strength)
