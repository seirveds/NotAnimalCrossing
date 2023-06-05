extends CanvasModulate

@onready var timer = $DayClock
@onready var animationPlayer = $AnimationPlayer
@onready var uiNode = get_tree().get_root().get_node("World/DateTimeUI")
@onready var timeLabel = uiNode.get_node("TimeLabel")
@onready var dateLabel = uiNode.get_node("DateLabel")

func _ready():
	startTimer()


func _process(_delta):
	var current_frame = remap(secondsPassed(), 0, Settings.DAYLENGTH, 0, 24)
	
	animationPlayer.play("DayNightCycle")
	animationPlayer.seek(current_frame)
	
	timeLabel.set("text", calculateClockTime(secondsPassed()))
	dateLabel.set("text", calculateSeason())


func startTimer():
	timer.start(Settings.DAYLENGTH)

func secondsPassed() -> float:
	return Settings.DAYLENGTH - timer.time_left

func calculateClockTime(seconds: float) -> String:
	var remappedSeconds = remap(seconds, 0, Settings.DAYLENGTH, 0, 24 * 60 * 60)
	var hours = floor(remappedSeconds / 3600)
	Globals.hour = hours
	var minutes = floor(fmod(remappedSeconds, 3600) / 60)
	return "%02d:%02d" % [hours, minutes]
	
func calculateSeason() -> String:
	# Use global day count to get season string
	var seasonDay = (Globals.day) % Settings.SEASONLENGTH
	var seasonIndex = fmod(floor((Globals.day) / Settings.SEASONLENGTH), 4)
	return "%s %02d" % [Settings.SEASONS[seasonIndex], seasonDay + 1]


func _on_day_clock_timeout():
	startTimer()
	Globals.day += 1
