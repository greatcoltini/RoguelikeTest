extends CharacterBody2D

# items for dropping
var hp_orb_item = preload("res://scenes/items/hp_orb.tscn")
var soul_shard_item = preload("res://scenes/items/soul_shard.tscn")
var enemy_slain_text = preload("res://scenes/overlay/enemy_slain.tscn")

#signals
signal damaged
signal removed


func select_new_direction(): pass
	
func pick_new_direction(): pass
		
func flip_sprite(): pass

# detect for players function
func attack(): pass
	
func hit(attacker, damage := 1): pass
		
func drop_items(soul_shard_amount, hp_orb_chance):
	# spawn enemy slain text
	var enemy_slain_text_inst = enemy_slain_text.instantiate()
	get_tree().current_scene.add_child(enemy_slain_text_inst)
	enemy_slain_text_inst.position = self.global_position
	# hp orb spawning
	var hp_orb_amount = randi_range(0, 100)
	if hp_orb_amount < hp_orb_chance:
		var hp_orb = hp_orb_item.instantiate()
		get_tree().current_scene.call_deferred("add_child", hp_orb)
		hp_orb.position = position
		
	# soul shard spawning
	for i in range(soul_shard_amount):
		var soul_shard = soul_shard_item.instantiate()
		get_tree().current_scene.call_deferred("add_child", soul_shard)
		soul_shard.position = position + Vector2(randi_range(-5, 5), randi_range(-5, 5))
	

