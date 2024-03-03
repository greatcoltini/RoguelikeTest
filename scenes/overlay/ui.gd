extends CanvasLayer

@onready var hp = $hp
@onready var soul_shards = $"soul-shards"
@onready var enemies_remaining = $enemiesRemaining
@onready var level_window = $'level-window'

@export var player : RigidBody2D
@export var main : Node2D

func _ready():
	main.level_cleared.connect(toggle_level_window)

func enemies_showcase():
	var ui_tweener = create_tween()
	ui_tweener.tween_property(enemies_remaining, "position", Vector2(235, 218), 0.1)
	ui_tweener.tween_property(enemies_remaining, "position", Vector2(764, 596), 1)
	
	var ui_size_tweener = create_tween()
	ui_size_tweener.tween_property(enemies_remaining, "scale", Vector2(3, 3), 0.1)
	ui_size_tweener.tween_property(enemies_remaining, "scale", Vector2(1.5, 1.5), 1)
	
	
func toggle_level_window():
	Globals.GAME_PAUSED = true
	if soul_shards.value >= 100:
		level_window.visible = true
