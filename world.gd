extends Node2D

# Width and height in pixels
# TODO maybe default tile size, instead of pixels
@export var width = 800
@export var height = 450

# RNG seed
@export var randomSeed = 1337

@onready var camera = $ysort/Alex/Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	seed(randomSeed)
	setCameraLimits()
	WorldGen.generateWorld(get_tree(), $Tilemap)
	
func _process(delta):
	if Input.is_action_just_pressed("ui_text_backspace"):
		WorldGen.clearWorld(get_tree())
		WorldGen.generateWorld(get_tree(), $Tilemap)


func setCameraLimits():
	camera.set("limit_left", 0)
	camera.set("limit_top", 0)
	camera.set("limit_right", width)
	camera.set("limit_bottom", height + (3 * Settings.TILESIZE))
