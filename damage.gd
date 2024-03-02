extends CharacterBody2D

var DAMAGE_AMOUNT = 1;
var SPEED = 5;

var direction

func _ready():
	var player = get_tree().get_first_node_in_group("Player");
	direction = player.position - position;
	
func _physics_process(delta):
	position += direction * delta;
	

# when player collides with blob, deal damage
func _on_body_entered(body):
	if body in get_tree().get_nodes_in_group("Player"):
		body.damage(self, DAMAGE_AMOUNT)
		queue_free()
