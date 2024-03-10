extends Node2D

# signals
signal level_cleared

var enemies_alive = 0
var enemies_to_spawn = 1
var current_level = 1
var current_region = "forest"

var mobs = []

var maps = [preload("res://scenes/levels/map1.tscn")]

@onready var ui = $UI
@onready var levelbar = $UI/enemiesRemaining

var map = null
var spawn_area = null
var starting_location = null
var dungeon_exit = null
@onready var player = $player


# Called when the node enters the scene tree for the first time.
func _ready():
	_start_game()
	player.scene_change.connect(_new_level)
	player.ui = ui;
	
# maybe we add pause and anim here
func _new_level():
	_clear_level()
	current_level += 1
	player.visible = false
	var level_timer = get_tree().create_timer(1)
	level_timer.timeout.connect(_start_game) # Replace with function body.
	
func _clear_level():
	var scene = get_tree().root.get_node("scene");
	for child in scene.get_children():
		if not child.is_in_group("Player") and not child.is_in_group("UI"):
			child.queue_free()
			
	
	
func _start_game():
	player.visible = true
	player.paused = false
	map = maps[randi() % int(maps.size())].instantiate()
	add_child(map)
	spawn_area = map.spawn_area
	starting_location = map.starting_area
	dungeon_exit = map.dungeon_exit
	# change this later to depend on stage level
	enemies_to_spawn = randi_range(1 + current_level, 2 + current_level)
	
	# add in animation for ui to show enemies
	ui.enemies_showcase()
	generate_enemy_list()
	
	# setup level bar
	levelbar.value = 100
	levelbar.step = (100 / enemies_to_spawn)
	
	var spawn_timer = get_tree().create_timer(randi_range(1, 3))
	spawn_timer.timeout.connect(spawn_enemy) # Replace with function body.
	place_player()

# spawning parameters for blobs..
func spawn_enemy():
	enemies_to_spawn -= 1
	enemies_alive += 1
	var enemy_index = randi_range(0, mobs.size() - 1)
	var enemy = mobs[enemy_index].instantiate()
	
	var cur_spawn_area = spawn_area[randi() % int(spawn_area.size())]
	
	
	var centerpos = cur_spawn_area.position;
	var size = cur_spawn_area.shape.extents
	var positionInArea = Vector2()
	positionInArea.x = (randi() % int(size.x)) - (size.x/2) + centerpos.x
	positionInArea.y = (randi() % int(size.y)) - (size.y/2) + centerpos.y
	
	while (positionInArea.distance_to(player.position) < 25):
		positionInArea.x = (randi() % int(size.x)) - (size.x/2) + centerpos.x
		positionInArea.y = (randi() % int(size.y)) - (size.y/2) + centerpos.y
	
	enemy.position = positionInArea
	enemy.removed.connect(self.decrement_enemies)
	add_child(enemy)
	
	if enemies_to_spawn > 0:
		var spawn_timer = get_tree().create_timer(randi_range(1, 3))
		spawn_timer.timeout.connect(spawn_enemy)
		
func generate_enemy_list():
	mobs = []
	for key in JsonData.monster_data.keys():
		var enemy = JsonData.monster_data[key]
		if enemy["region"] == current_region and int(enemy["level_min"]) <= current_level:
			for i in range(enemy["weight"]):
				mobs.append(load(enemy["file_path"]))
	for i in range(mobs.size()):
		print(mobs[i].resource_path)
	

# decrement enemies when kill
func decrement_enemies():
	enemies_alive -= 1
	levelbar.value -= levelbar.step
	
	if enemies_to_spawn <= 0 and enemies_alive <= 0:
		dungeon_exit.get_node("AnimationPlayer").play("open")
		dungeon_exit.get_node("Area2D").monitoring = true
		dungeon_exit.get_node("Interact").visible = true
		current_level += 1
		emit_signal("level_cleared")
		
		
# sets up the initial level parameters		
func setup():
	map = maps[randi() % int(maps.size())].instantiate()
	add_child(map)
	
	spawn_area = map.spawn_area
	starting_location = map.starting_area
	dungeon_exit = map.dungeon_exit
	
	place_player()
	
	
### PLAYER RELATED FUNCTIONS ###
func place_player():
	var centerpos = starting_location.position;
	var size = starting_location.shape.extents
	var positionInArea = Vector2i()
	positionInArea.x = (randi() % int(size.x)) - (size.x/2) + centerpos.x
	positionInArea.y = (randi() % int(size.y)) - (size.y/2) + centerpos.y
	
	player.position = positionInArea
	
