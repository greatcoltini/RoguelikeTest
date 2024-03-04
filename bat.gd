extends "res://enemy.gd"



func _ready():
	anim_tree = $AnimationTree
	state_machine = anim_tree.get("parameters/playback")
	state_machine.start("move")	
	
