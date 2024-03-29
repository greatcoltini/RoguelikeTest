extends "res://enemy.gd"

# BLOB CONSTANTS
const SOUL_SHARDS = 5
const HP_ORB_CHANCE = 20
const DAMAGE_AMOUNT = 1
const WALK_TIME = 6
const IDLE_TIME = 2
const MOVE_SPEED = 3
const CHASING_SPEED = 15
const MAX_HEALTH = 3

# initialize variables for relative parts of entity
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var collider = $CollisionShape2D
@onready var state_machine = anim_tree.get("parameters/playback")
@onready var timer = $Timer
@onready var hittimer = $Timer2

var item_drop = preload("res://entities/items/ItemDrop.tscn")
var surprise = preload("res://entities/effects/surprise_indicator.tscn")
var damage_particle = preload("res://entities/particles/damage_particle.tscn")
var recoil = false
var player
var enraged = false

var fellow_blobs = []


enum STATE { IDLE, JUMP, CHASING, SLEEPING, DEATH }

const IDLE_STATES = [STATE.IDLE, STATE.SLEEPING, STATE.DEATH]
var current_state = STATE.IDLE



var move_direction : Vector2 = Vector2.ZERO
var Daynight
var sleep_time
var current_health = MAX_HEALTH


func _ready():
	state_machine.start("idle")
	select_new_direction()
	pick_new_state()
	current_health = MAX_HEALTH

# idle function
func _physics_process(_delta):
	# run idle animation, on idle animation end decide to jump
	if current_state == STATE.DEATH or current_health == 0:
		state_machine.travel("death")
		return
		
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
		
func pick_new_state():
	if current_state != STATE.SLEEPING:
		if current_state != STATE.CHASING:
			if current_state == STATE.IDLE:
				# changes to walk state
				state_machine.travel("jump")
				current_state = STATE.JUMP
				select_new_direction()
				timer.start(WALK_TIME)
			else:
				# changes to idle state
				state_machine.travel("idle")
				current_state = STATE.IDLE
				timer.start(IDLE_TIME)
		else:
			state_machine.travel("jump")
	else:
		state_machine.travel("go-sleep")
	
# when player collides with blob, deal damage
func _on_body_entered(body):
	if body in get_tree().get_nodes_in_group("Player"):
		body.damage(self, DAMAGE_AMOUNT)

func _on_timer_timeout():
	pick_new_state()
	
func hit(attacker, damage := 1):
	var damage_part = damage_particle.instantiate()

	add_child(damage_part)
	damage_part.position = sprite.position	
	if current_health > 0:
		# send in attacker info, create vector from self to attack, use that to direct
		velocity = (sprite.global_position - attacker.sprite.global_position) * 5
		recoil = true
		hittimer.start(0.15)
		current_health -= damage
		emit_signal("damaged")
		#animation_player.play("damage")
		# create on-hit particle
	#	var damage_part = damage_particle.instantiate()
	#	add_child(damage_part)
	#	damage_part.position = sprite.position
		
		
	if current_health <= 0:
		timer.paused = true
		current_state = STATE.DEATH
		kill()

func kill():
	state_machine.travel("death")

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "death":
		collider.disabled = true
		anim_tree.active = false
		emit_signal("removed")
		super.drop_items(SOUL_SHARDS, HP_ORB_CHANCE)
		queue_free()
		
		
func enrage():
	timer.stop()
	current_state = STATE.CHASING
	enraged = true
	
	for i in range(fellow_blobs.size()):
		if not fellow_blobs[i].enraged:
			fellow_blobs[i].spawn_surprise()
			fellow_blobs[i].enrage()
		
	flip_sprite()
	state_machine.travel("jump")


func _on_timer_2_timeout():
	recoil = false
	if current_health > 0:
		enrage()


func _on_detection_radius_body_entered(body):
	if body in get_tree().get_nodes_in_group("Player") and not current_state == STATE.SLEEPING:
		spawn_surprise()
		current_state = STATE.CHASING
		player = body
		
	if body in get_tree().get_nodes_in_group("Blob"):
		fellow_blobs.append(body)
		
func spawn_surprise():
	if not (enraged):
		var indicator = surprise.instantiate()
		add_child(indicator)
		
func _on_detection_radius_body_exited(body):
	if body in get_tree().get_nodes_in_group("Player") and not current_state == STATE.SLEEPING:
		current_state = STATE.IDLE
		pick_new_state()
		
	if body in get_tree().get_nodes_in_group("Blob"):
		fellow_blobs.erase(body)
