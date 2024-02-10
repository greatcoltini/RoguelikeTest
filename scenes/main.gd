extends Node2D

var blob_count = 0

var blob_file = preload("res://scenes/entities/blob.tscn")

@export var spawn_area = Area2D
@export var spawn_shape = CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	while blob_count < 5:
		var spawn_timer = get_tree().create_timer(randi_range(5, 15))
		spawn_timer.timeout.connect(spawn_blob)
		blob_count += 1
		
		
func spawn_blob():
	var blob = blob_file.instantiate()
	
	var centerpos = spawn_shape.position;
	var size = spawn_shape.shape.extents
	var positionInArea = Vector2i()
	positionInArea.x = (randi() % int(size.x)) - (size.x/2) + centerpos.x
	positionInArea.y = (randi() % int(size.y)) - (size.y/2) + centerpos.y
	
	blob.position = positionInArea
	add_child(blob)
	
	
