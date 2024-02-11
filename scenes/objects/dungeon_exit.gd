extends Node2D

@onready var interact = $Interact


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if body == get_tree().get_first_node_in_group("Player"):
		body.in_exit_zone = true
		interact.modulate.a = 1.0



func _on_area_2d_body_exited(body):
	if body == get_tree().get_first_node_in_group("Player"):
		body.in_exit_zone = false # Replace with function body.
		interact.modulate.a = 0.5
