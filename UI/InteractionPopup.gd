extends Node

@onready var popup = $Background
@onready var textbox = $Background/Label


# Called when the node enters the scene tree for the first time.
func _ready():
	popup.visible = false
	
func _input(event):
	if popup.visible and Input.is_action_just_pressed("interact"):
		popup.visible = false


func set_text(text: String):
	textbox.set("text", text)

func open():
	popup.visible = true

func open_with_text(text: String):
	set_text(text)
	open()
