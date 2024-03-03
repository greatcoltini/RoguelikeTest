extends Node2D

@onready var area = $Sprite2D/Area2D;
@onready var sprite = $Sprite2D
var anim_tree;

# variables for weapon positioning
var mouse_pos;
var direction
var new_angle;
var attacking;
var can_attack;
var damage = 1;


var current_hitters = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0.5
	area.monitoring = false; # Replace with function body.
	can_attack = true
	
	
func _physics_process(delta):
	if not Globals.GAME_PAUSED:
		if not attacking:
			# get vector from weapon to mouse position
			mouse_pos = get_local_mouse_position()
			direction = (sprite.position - mouse_pos).normalized()
			
			# create angle out of this vector
			new_angle = (1.75*PI) + atan2(direction.y, direction.x)
			
			sprite.rotation = new_angle;
		
func _input(event: InputEvent):
	if (event.is_action_pressed("attack") and can_attack):
		toggle_attack()
		modulate.a = 1.0
		var tween = create_tween()
		var cur_pos = position
		tween.tween_property(self, "position", -direction * 15, 0.1)
		tween.tween_property(self, "position", position, 0.1)
		tween.tween_callback(toggle_attack)
		
		
	
func toggle_attack():
	can_attack = !can_attack
	modulate.a = 0.5
	area.monitoring = !area.monitoring
	attacking = !attacking


func _on_area_2d_body_entered(body):
	
	if not anim_tree:
		anim_tree = get_parent().anim_tree
		
	if self in body.get_children():
		return;
	
	if not (body in current_hitters):
		if body.has_method("hit"):
			body.hit(self, damage)
		current_hitters.append(body)
		# Create a one-shot timer with a timeout function using a lambda function
		var hit_timer = get_tree().create_timer(0.2)
		hit_timer.timeout.connect(_clear_bodys)

func _clear_bodys():
	current_hitters.clear()

func _on_area_2d_body_exited(body):
	if self in body.get_children():
		pass;
	else:
		print(body); # Replace with function body. # Replace with function body.
		
func increase_damage():
	self.damage += 1
