extends ProgressBar




func _ready():
	call_deferred("set_value", get_parent().current_health)
	max_value = get_parent().MAX_HEALTH
	
	get_parent().damaged.connect(update_health)
	
	
func update_health():
	value = get_parent().current_health
	
