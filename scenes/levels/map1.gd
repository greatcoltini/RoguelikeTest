extends Node2D


@onready var spawn_area = $'spawn-area'.get_children()
@export var starting_area = CollisionShape2D
@export var dungeon_exit = Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var spawn_area = $"spawn-area".get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
