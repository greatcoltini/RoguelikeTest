extends CharacterBody2D

@onready var sprite = $Sprite2D

var DAMAGE_AMOUNT = 1;
var SPEED = 100;

var direction

func _ready():
	var player = get_tree().get_first_node_in_group("Player");
	direction = (player.position - position).normalized();
		
	# create angle out of this vector
	var angle = (1.75*PI) + atan2(direction.y, direction.x)
		
	sprite.rotation = angle;
	
func _physics_process(delta):
	position += direction * SPEED * delta;
	

# when player collides with blob, deal damage
func _on_body_entered(body):
	if body in get_tree().get_nodes_in_group("Player"):
		body.damage(self, DAMAGE_AMOUNT)
		queue_free()
