extends Node2D

var enemies_alive = 0
var enemies_to_spawn = 1

var blob_file = preload("res://scenes/entities/blob.tscn")

var maps = [preload("res://scenes/levels/map1.tscn")]

var map = null
var spawn_area = null
var starting_location = null
var dungeon_exit = null
@onready var player = $player


# Called when the node enters the scene tree for the first time.
func _ready():
	_start_game()
	player.scene_change.connect(_new_level)
	
# maybe we add pause and anim here
func _new_level():
	player.visible = false
	var level_timer = get_tree().create_timer(3)
	level_timer.timeout.connect(_start_game) # Replace with function body.
	
	
func _start_game():
	player.visible = true
	player.paused = false
	map = maps[randi() % int(maps.size())].instantiate()
	add_child(map)
	spawn_area = map.spawn_area
	starting_location = map.starting_area
	dungeon_exit = map.dungeon_exit
	# change this later to depend on stage level
	enemies_to_spawn = randi_range(1, 1)
	var spawn_timer = get_tree().create_timer(randi_range(5, 15))
	spawn_timer.timeout.connect(spawn_blob) # Replace with function body.
	place_player()

# spawning parameters for blobs..
func spawn_blob():
	enemies_to_spawn -= 1
	enemies_alive += 1
	var blob = blob_file.instantiate()
	
	var cur_spawn_area = spawn_area[randi() % int(spawn_area.size())]
	
	var centerpos = cur_spawn_area.position;
	var size = cur_spawn_area.shape.extents
	var positionInArea = Vector2i()
	positionInArea.x = (randi() % int(size.x)) - (size.x/2) + centerpos.x
	positionInArea.y = (randi() % int(size.y)) - (size.y/2) + centerpos.y
	
	blob.position = positionInArea
	blob.removed.connect(self.decrement_enemies)
	add_child(blob)
	
	if enemies_to_spawn > 0:
		var spawn_timer = get_tree().create_timer(randi_range(5, 15))
		spawn_timer.timeout.connect(spawn_blob)
	

# decrement enemies when kill
func decrement_enemies():
	enemies_alive -= 1
	
	if enemies_to_spawn <= 0 and enemies_alive <= 0:
		dungeon_exit.get_node("AnimationPlayer").play("open")
		dungeon_exit.get_node("Area2D").monitoring = true
		dungeon_exit.get_node("Interact").visible = true
		

		
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
	
