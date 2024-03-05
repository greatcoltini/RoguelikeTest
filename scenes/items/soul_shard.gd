extends StaticBody2D

const SPEED = 100

var player
var direction
var movement_enabled = false

func _ready():
	var delay = get_tree().create_timer(1)
	delay.timeout.connect(func(): movement_enabled = true)
	player = get_tree().get_first_node_in_group("Player");

func _physics_process(delta):
	
	if movement_enabled and player:
		player = get_tree().get_first_node_in_group("Player");
		direction = (player.position - position).normalized();
		position += direction * SPEED * delta;
		
func _on_area_2d_body_entered(body):
	if body == player:
		player.add_souls(1)
		queue_free()
		
