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
	
	var targetNode = tree.get_root().get_node(Settings.BUGSNODEPATH)
	
	if bugCount < Settings.MAXBUGS:
#		spawnBug(tree)
		var factory = load("res://Critters/Butterfly.tscn")
		var instance = factory.instantiate()
		instance._init("Emperor_Butterfly.png")
		targetNode.add_child(instance)
		instance.global_position = Vector2i(64, 64)
	
func setCameraLimits():
	camera.set("limit_left", 0)
	camera.set("limit_top", 0)
	camera.set("limit_right", Settings.WIDTH * Settings.TILESIZE)
	camera.set("limit_bottom", Settings.HEIGHT * Settings.TILESIZE + (3 * Settings.TILESIZE))

func spawnBug(tree: SceneTree):
	var bug = ["Butterfly", "Firefly"].pick_random()
	var bugNode = load("res://Critters/%s.tscn" % bug)
	WorldGen.placeAtRandomPosition(
		tree,
		Settings.BUGSNODEPATH,
		"res://Critters/%s.tscn" % bug,
		1, # Amount
		0, # Border
	)
