extends Sprite

var target = Vector2(0, 0)
var fading_in = true

func _ready():
	modulate.a = 0

func _process(delta):
	if target == Vector2(0, 0):
		queue_free()
	global_position = lerp(global_position, target, 0.02)
	if fading_in:
		modulate.a += 0.1
		if modulate.a >= 1:
			fading_in = false
	else:
		modulate.a -= 0.01
		if modulate.a <= 0:
			queue_free()
