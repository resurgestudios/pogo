extends Area2D

var move : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += move * delta

func _on_body_entered(body):
	if body == Global.Player:
		body.focus.append(self)
		body.focus_updated()
		
		
func _on_body_exited(body):
	if body == Global.Player:
		body.focus.erase(self)
		body.focus_updated()
		
