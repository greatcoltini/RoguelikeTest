extends CharacterBody2D

# BLOB CONSTANTS
const DAMAGE_AMOUNT = 10
const WALK_TIME = 6
const IDLE_TIME = 2
const MOVE_SPEED = 15
const MAX_HEALTH = 3

#signals
signal damaged
signal removed

# initialize variables for relative parts of entity
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var collider = $CollisionShape2D
@onready var state_machine = anim_tree.get("parameters/playback")

var surprise = preload("res://entities/effects/surprise_indicator.tscn")
var damage_particle = preload("res://entities/particles/damage_particle.tscn")
var projectile = preload("res://scenes/entities/bat_projectile.tscn")

var recoil = false
var player
var enraged = false
var can_attack = true

enum STATE { MOVE, ATTACK, DEATH }

var current_state = STATE.MOVE

var move_direction : Vector2 = Vector2.ZERO
var current_health = MAX_HEALTH


func _ready():
	state_machine.start("move")
	select_new_direction()
	current_health = MAX_HEALTH

# idle function
func _physics_process(_delta):
	# run idle animation, on idle animation end decide to jump

	if (current_state == STATE.DEATH):
		return
	if (current_state == STATE.MOVE):
		velocity = move_direction.normalized() * MOVE_SPEED	
		move_and_slide()
		
	attack()
	
func select_new_direction():
	move_direction = Vector2(
		randi_range(-1, 1),
		randi_range(-1, 1)
	)
	flip_sprite()
	
func pick_new_direction():
	select_new_direction()
	var move_timer = get_tree().create_timer(WALK_TIME)
	move_timer.timeout.connect(pick_new_direction)
		
func flip_sprite():
	if move_direction.x < 0:
		sprite.flip_h = true
	elif move_direction.x > 0:
		sprite.flip_h = false

# detect for players function
func attack():
	""" we will raycast for the player, if it is within a certain range we will adjust ai
		and jump towards player specifically"""
	var player = get_tree().get_first_node_in_group("Player");
	
	if (player and (self.position.distance_to(player.position) < 50) and can_attack):
		current_state = STATE.ATTACK
		can_attack = false
		state_machine.travel("attack");
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.5, 0.5)
		tween.tween_property(self, "modulate:a", 1, 0.1)
		tween.tween_callback(fire_attack)
		
		var attack_timeout = get_tree().create_timer(0.9)
		attack_timeout.timeout.connect(func(): 
			can_attack = !can_attack
			pick_new_direction()
			current_state = STATE.MOVE);
			
func finish_attack():
	can_attack = !can_attack
	pick_new_direction();
		
func fire_attack():
	var fire_projectile = projectile.instantiate()
	get_tree().current_scene.call_deferred("add_child", fire_projectile)
	fire_projectile.position = position
	
func hit(attacker):
	var damage_part = damage_particle.instantiate()

	add_child(damage_part)
	damage_part.position = sprite.position	
	if current_health > 0:
		# send in attacker info, create vector from self to attack, use that to direct
		velocity = (sprite.global_position - attacker.sprite.global_position) * 15
		recoil = true
		current_health -= 1
		emit_signal("damaged")
		
	if current_health <= 0:
		current_state = STATE.DEATH
		kill()

func kill():
	state_machine.travel("death")

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "death":
		collider.disabled = true
		anim_tree.active = false
		emit_signal("removed")
		queue_free()
		

func _on_timer_2_timeout():
	recoil = false


func _on_detection_radius_body_entered(body):
	if body in get_tree().get_nodes_in_group("Player"):
		spawn_surprise()
		player = body
		
func spawn_surprise():
	if not (enraged):
		var indicator = surprise.instantiate()
		add_child(indicator)
		
