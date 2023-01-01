extends Area2D

var move : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func is_slowmo_area():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	global_position += move * delta
	

func _on_body_entered(body) -> void:
	if body == Global.Player:
		show_outline()
		body.focus.append(self)
		body.focus_updated()
		

func _on_body_exited(body) -> void:
	if body == Global.Player:
		hide_outline()
		body.focus.erase(self)
		body.focus_updated()
		
		
func show_outline() -> void:
	var tween : Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).tween_property($Outline, "modulate:a", 1, 0.1)

func hide_outline() -> void:
	var tween : Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).tween_property($Outline, "modulate:a", 0, 0.1)
