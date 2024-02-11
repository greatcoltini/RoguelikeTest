extends Node2D

var enemies_alive = 0
var enemies_to_spawn = 1

var blob_file = preload("res://scenes/entities/blob.tscn")

@export var spawn_area = Area2D
@export var spawn_shape = CollisionShape2D

@onready var exit = $"dungeon-exit"

# Called when the node enters the scene tree for the first time.
func _ready():
	var spawn_timer = get_tree().create_timer(randi_range(5, 15))
	spawn_timer.timeout.connect(spawn_blob) # Replace with function body.

func spawn_blob():
	enemies_to_spawn -= 1
	enemies_alive += 1
	var blob = blob_file.instantiate()
	
	var centerpos = spawn_shape.position;
	var size = spawn_shape.shape.extents
	var positionInArea = Vector2i()
	positionInArea.x = (randi() % int(size.x)) - (size.x/2) + centerpos.x
	positionInArea.y = (randi() % int(size.y)) - (size.y/2) + centerpos.y
	
	blob.position = positionInArea
	blob.removed.connect(self.decrement_enemies)
	add_child(blob)
	
	if enemies_to_spawn > 0:
		var spawn_timer = get_tree().create_timer(randi_range(5, 15))
		spawn_timer.timeout.connect(spawn_blob)
	
	
func decrement_enemies():
	enemies_alive -= 1
	
	if enemies_to_spawn <= 0 and enemies_alive <= 0:
		exit.get_node("AnimationPlayer").play("open")
		exit.get_node("Area2D").monitoring = true
		exit.get_node("Interact").visible = true
	
	
