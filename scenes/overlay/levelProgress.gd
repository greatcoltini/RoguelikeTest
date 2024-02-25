extends ProgressBar


# animate progress bar
func increment(val):
	value += 0.1
	if val > 0:
		var inc_timer = get_tree().create_timer(0.1)
		inc_timer.timeout.connect(increment, val - 0.1)
