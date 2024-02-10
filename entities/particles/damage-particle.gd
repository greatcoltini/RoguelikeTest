extends Node2D

@onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("play")
	pass # Replace with function body.

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
