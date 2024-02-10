extends Node2D

@onready var area = $Sprite2D/Area2D;
@onready var sprite = $Sprite2D
var anim_tree;

var current_hitters = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	area.monitoring = false; # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	
	if not anim_tree:
		anim_tree = get_parent().anim_tree
		
	if self in body.get_children():
		return;
	
	if body in current_hitters:
		print("already hit")
	else:
		if body.has_method("hit"):
			body.hit(self)
		current_hitters.append(body)
		# Create a one-shot timer with a timeout function using a lambda function
		var hit_timer = get_tree().create_timer(anim_tree.get_animation("attack_down").length)
		hit_timer.timeout.connect(_clear_bodys)

func _clear_bodys():
	current_hitters.clear()
	


func _on_area_2d_body_exited(body):
	if self in body.get_children():
		pass;
	else:
		print(body); # Replace with function body. # Replace with function body.
