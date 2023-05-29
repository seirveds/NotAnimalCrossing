extends Node2D

# RNG seed
@export var randomSeed = 1337

@onready var camera = $ysort/Alex/Camera2D
@onready var tilemap = $Tilemap
@onready var tree = get_tree()


# Called when the node enters the scene tree for the first time.
func _ready():
	seed(randomSeed)
	setCameraLimits()
	WorldGen.generateWorld(tree, tilemap)
	
func _process(delta):

	if Input.is_action_just_pressed("ui_text_backspace"):
		WorldGen.clearWorld(tree, tilemap)
		WorldGen.generateWorld(tree, tilemap)
		
	# Main loop
	var bugCount = tree.get_root().get_node(Settings.BUGSNODEPATH).get_child_count()
	if bugCount < Settings.MAXBUGS:
		spawnBug(tree)
	
func setCameraLimits():
	camera.set("limit_left", 0)
	camera.set("limit_top", 0)
	camera.set("limit_right", Settings.WIDTH * Settings.TILESIZE)
	camera.set("limit_bottom", Settings.HEIGHT * Settings.TILESIZE + (3 * Settings.TILESIZE))

func spawnBug(tree: SceneTree):
	WorldGen.placeAtRandomPosition(
		tree,
		Settings.BUGSNODEPATH,
		"res://Critters/Butterfly.tscn",
		1, # Amount
		0, # Border
	)
