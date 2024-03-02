extends StaticBody2D

const SPEED = 50

var player
var direction


func _ready():
	var player = get_tree().get_first_node_in_group("Player");
	if player.health < player.MAX_HP:
		direction = (player.position - position).normalized();
		
func _physics_process(delta):
	
	player = get_tree().get_first_node_in_group("Player");
	if (player and player.health < player.MAX_HP):
		direction = (player.position - position).normalized();
		position += direction * SPEED * delta;
	
# if player is not full health; player absorbs
func _on_area_2d_body_entered(body):
	if player and player == body and player.health < player.MAX_HP:
		player.heal(1)
		queue_free()
		
