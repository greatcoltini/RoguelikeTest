extends CharacterBody2D

# signals
signal weapon_end
signal scene_change

# export variables
@export var move_speed : float = 100
@export var starting_position : Vector2 = Vector2(0, 1)

@export var weaponComponent = Node2D;

@export var sprite = Sprite2D
@export var anim_player = AnimationPlayer

@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")


# init regular variables
var paused = false
var in_exit_zone = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

	
func _physics_process(_delta):
	# get input direction
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if not paused:
		if not input_direction == Vector2.ZERO:
			input_direction = input_direction.normalized()
		velocity = input_direction * move_speed	
		
		update_animation_parameters(input_direction)
		move_and_slide()
		pick_new_state()

func _input(event: InputEvent):
	
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if not input_direction == Vector2.ZERO:
			input_direction = input_direction.normalized()
	
	if (event.is_action_pressed("space") and not paused):
		anim_tree.set("parameters/Attack/blend_position", input_direction)
		state_machine.travel("Attack")
		weaponComponent.area.monitoring = true;
		paused = true;
		
	# check case for exit area
	if (event.is_action_pressed("interact") and not paused and in_exit_zone):
		paused = true
		emit_signal("scene_change")
		
		
		
func update_animation_parameters(move_input : Vector2):
	if (move_input != Vector2.ZERO):
		anim_tree.set("parameters/Walk/blend_position", move_input)
		anim_tree.set("parameters/Idle/blend_position", move_input)
		
# changes animations depending on the input given
func pick_new_state():
	if (velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

func _on_animation_tree_animation_finished(anim_name):
	if (anim_name.contains("attack") || anim_name.contains("Attack")):
		paused = false; # Replace with function body. # Replace with function body.
		weaponComponent.area.monitoring = false
		emit_signal("weapon_end")
