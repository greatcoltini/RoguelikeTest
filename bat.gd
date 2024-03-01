extends CharacterBody2D

# BLOB CONSTANTS
const DAMAGE_AMOUNT = 10
const WALK_TIME = 6
const IDLE_TIME = 2
const MOVE_SPEED = 3
const CHASING_SPEED = 15
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
var recoil = false
var player
var enraged = false

enum STATE { IDLE, JUMP, CHASING, DEATH }

const IDLE_STATES = [STATE.IDLE, STATE.DEATH]
var current_state = STATE.IDLE

var move_direction : Vector2 = Vector2.ZERO
var current_health = MAX_HEALTH


func _ready():
	state_machine.start("idle")
	select_new_direction()
	current_health = MAX_HEALTH

# idle function
func _physics_process(_delta):
	# run idle animation, on idle animation end decide to jump
	
	if not recoil:
		if current_state == STATE.JUMP:
			velocity = move_direction.normalized() * MOVE_SPEED	
			
		if current_state == STATE.CHASING:
			
			flip_sprite()
			player = get_tree().get_first_node_in_group("Player")
			move_direction = player.sprite.global_position - sprite.global_position
			velocity = move_direction.normalized() * CHASING_SPEED
			#print(move_direction)
				
	if not current_state in IDLE_STATES:
		move_and_slide()
	
func select_new_direction():
	move_direction = Vector2(
		randi_range(-1, 1),
		randi_range(-1, 1)
	)
	flip_sprite()
		
func flip_sprite():
	if move_direction.x < 0:
		sprite.flip_h = true
	elif move_direction.x > 0:
		sprite.flip_h = false

# detect for players function
func attack_in_range():
	""" we will raycast for the player, if it is within a certain range we will adjust ai
		and jump towards player specifically"""
#	var query = PhysicsRayQueryParameters2D.create(sprite.global_position, move_direction.normalized() * (move_speed * 50))
#	var results = space_state.intersect_ray(query)
#	if results:
#		#print("position of item: ", results.position)
#		#print("distance_to: ", sprite.global_position.distance_to(results.position))
#		if sprite.global_position.distance_to(results.position) < 20:
#			select_new_direction()	
	
# when player collides with blob, deal damage
func _on_body_entered(body):
	if body in get_tree().get_nodes_in_group("Player"):
		body.damage(self, DAMAGE_AMOUNT)
	
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
		#animation_player.play("damage")
		# create on-hit particle
	#	var damage_part = damage_particle.instantiate()
	#	add_child(damage_part)
	#	damage_part.position = sprite.position
		
		
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
		current_state = STATE.CHASING
		player = body
		
func spawn_surprise():
	if not (enraged):
		var indicator = surprise.instantiate()
		add_child(indicator)
		
func _on_detection_radius_body_exited(body):
	if body in get_tree().get_nodes_in_group("Player"):
		current_state = STATE.IDLE
