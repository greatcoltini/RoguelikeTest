extends Node2D

@onready var area = $Sprite2D/Area2D;

var current_hitters = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	area.monitoring = false; # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if self in body.get_children():
		return;
	
	if body in current_hitters:
		print("already hit")
	else:
		print("new hit")
		current_hitters.append(body)
		
	


func _on_area_2d_body_exited(body):
	if self in body.get_children():
		pass;
	else:
		print(body); # Replace with function body. # Replace with function body.
