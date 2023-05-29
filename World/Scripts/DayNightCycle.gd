extends CanvasModulate

@onready var timer = $DayClock
@onready var animationPlayer = $AnimationPlayer


func _ready():
	startTimer()


func _process(_delta):
	var current_frame = remap(secondsPassed(), 0, Settings.DAYLENGTH, 0, 24)
	
	animationPlayer.play("DayNightCycle")
	animationPlayer.seek(current_frame)
	
	print(secondsPassed(), " ", calculateClockTime(secondsPassed()))


func startTimer():
	timer.start(Settings.DAYLENGTH)

func secondsPassed() -> float:
	return Settings.DAYLENGTH - timer.time_left

func calculateClockTime(seconds: float) -> String:
	var remappedSeconds = remap(seconds, 0, Settings.DAYLENGTH, 0, 24 * 60 * 60)
	var hours = floor(remappedSeconds / 3600)
	var minutes = floor(fmod(remappedSeconds, 3600) / 60)
	return "%02d:%02d" % [hours, minutes]


func _on_day_clock_timeout():
	startTimer()
	Globals.day += 1
