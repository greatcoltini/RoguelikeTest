extends Node

# plays damage animation on target object
func DAMAGE_EFFECT(obj, sprite, duration):
	var tween = obj.get_tree().create_tween()
	
	for i in range(duration * 5):
		tween.tween_property(sprite, "modulate:a", 0.5, 0.1)
		tween.tween_property(sprite, "modulate:a", 1, 0.1)
		
