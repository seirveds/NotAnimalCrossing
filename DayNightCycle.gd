extends CanvasModulate

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var seconds = fmod(Time.get_unix_time_from_system(), 60)
	
	var current_frame = remap(seconds, 0, 60, 0, 24)
	
	$AnimationPlayer.play("DayNightCycle")
	$AnimationPlayer.seek(current_frame)
