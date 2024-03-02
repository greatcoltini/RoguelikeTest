extends CanvasLayer

@onready var hp = $hp
@onready var soul_shards = $"soul-shards"
@onready var enemies_remaining = $enemiesRemaining


func enemies_showcase():
	var ui_tweener = create_tween()
	ui_tweener.tween_property(enemies_remaining, "position", Vector2(235, 218), 0.1)
	ui_tweener.tween_property(enemies_remaining, "position", Vector2(764, 596), 1)
	
	var ui_size_tweener = create_tween()
	ui_size_tweener.tween_property(enemies_remaining, "scale", Vector2(3, 3), 0.1)
	ui_size_tweener.tween_property(enemies_remaining, "scale", Vector2(1.5, 1.5), 1)
