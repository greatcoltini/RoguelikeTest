extends "res://enemy.gd"

# CONSTANTS
const DAMAGE_AMOUNT = 10
const WALK_TIME = 6
const RECOIL_TIMER = 1
const MOVE_SPEED = 25
const MAX_HEALTH = 3
const ATTACK_DELAY = 2
const SOUL_SHARDS = 5
const HP_ORB_CHANCE = 30

# exports for constructor use
@export var sprite : Sprite2D
var anim_tree
@export var anim_player = AnimationPlayer
@export var collider = CollisionShape2D

var state_machine
var in_attack_cycle

var surprise = preload("res://entities/effects/surprise_indicator.tscn")
var damage_particle = preload("res://entities/particles/damage_particle.tscn")


var player
var can_attack = true

enum STATE { IDLE, MOVE, ATTACK, DEATH, RECOIL }

var current_state = STATE.MOVE

var move_direction : Vector2 = Vector2.ZERO
var current_health = MAX_HEALTH


func _ready():
	anim_tree = $AnimationTree
	player = get_tree().get_first_node_in_group("Player")
	state_machine = anim_tree.get("parameters/playback")
	state_machine.start("walk")	
	select_new_direction()
	current_health = MAX_HEALTH

# idle function
func _physics_process(_delta):
	# run idle animation, on idle animation end decide to jump
	if current_health <= 0:
			state_machine.travel("death")
	if (current_state == STATE.DEATH):
		return
		
	if not in_attack_cycle:
		if (current_state == STATE.MOVE or current_state == STATE.RECOIL):
			if (self.position.distance_to(player.position) < 50):
				current_state = STATE.IDLE
				velocity = Vector2.ZERO
				state_machine.travel("idle")
			else:
				velocity = move_direction.normalized() * MOVE_SPEED	
				state_machine.travel("walk")
			move_and_slide()
		if (current_state == STATE.IDLE and self.position.distance_to(player.position) > 25):
			state_machine.travel("idle")
			pick_state()
		
		attack()
	
func select_new_direction():
	if player:
		move_direction = position.direction_to(player.position)
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
	var player = get_tree().get_first_node_in_group("Player");
	
	if (player and (self.position.distance_to(player.position) < 50) and can_attack):
		velocity = Vector2.ZERO
		# faces player when attacking
		sprite.flip_h = self.to_local(player.global_position).x < 0
		current_state = STATE.ATTACK
		can_attack = false
		in_attack_cycle = true
		state_machine.travel("attack_1");
		#var tween = create_tween()
		#tween.tween_property(self, "modulate:a", 0.5, 0.5)
		#tween.tween_property(self, "modulate:a", 1, 0.1)
		#tween.tween_callback(fire_attack)
			
		
			
		#
#func fire_attack():
	#var fire_projectile = projectile.instantiate()
	#get_tree().current_scene.call_deferred("add_child", fire_projectile)
	#fire_projectile.position = position
	#current_state = STATE.MOVE
	#pick_new_direction()
	
func hit(attacker, damage := 1):
	var damage_part = damage_particle.instantiate()

	add_child(damage_part)
	damage_part.position = sprite.position	
	if current_health > 0:
		# send in attacker info, create vector from self to attack, use that to direct
		velocity = (sprite.global_position - attacker.sprite.global_position).normalized() * 50
		current_state = STATE.RECOIL
		# oneshot timer to reset state after recoil
		var recoil_timeout = get_tree().create_timer(RECOIL_TIMER)
		recoil_timeout.timeout.connect(func(): current_state = STATE.MOVE)
		current_health -= damage
		emit_signal("damaged")
		
	if current_health <= 0:
		current_state = STATE.DEATH
		state_machine.travel("death")

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "death":
		collider.disabled = true
		anim_tree.active = false
		emit_signal("removed")
		super.drop_items(SOUL_SHARDS, HP_ORB_CHANCE)
		queue_free()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack_1":
		in_attack_cycle = false # Replace with function body.
		# timeout for bat attack method
		var attack_timeout = get_tree().create_timer(ATTACK_DELAY)
		attack_timeout.timeout.connect(func(): 
			can_attack = !can_attack);
		pick_state()
		
		
func pick_state():
	if self.position.distance_to(player.position) < 25:
		current_state = STATE.IDLE
		state_machine.start("idle")
	else:
		current_state = STATE.MOVE
		state_machine.start("walk")
		pick_new_direction()
