extends Node2D

# RNG seed
@export var randomSeed = 1337

@onready var camera = $ysort/Player/Camera
@onready var tilemap = $Tilemap
@onready var tree = get_tree()
@onready var bugNode = tree.get_root().get_node(Settings.BUGSNODEPATH)

@onready var player = $ysort/Player
@onready var inventory_interface = $UI/Inventory/InventoryInterface
	
# Called when the node enters the scene tree for the first time.
func _ready():
	seed(randomSeed)
	setCameraLimits()
	WorldGen.generateWorld(tree, tilemap)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	
func _process(delta):

	if Input.is_action_just_pressed("ui_text_backspace"):
		WorldGen.clearWorld(tree, tilemap)
		WorldGen.generateWorld(tree, tilemap)
		
	# Main loop
	var bugCount = bugNode.get_child_count()
		
	if bugCount < Settings.MAXBUGS:
		spawnBug(tree)
	
func setCameraLimits():
	camera.set("limit_left", 0)
	camera.set("limit_top", 0)
	camera.set("limit_right", Settings.WIDTH * Settings.TILESIZE)
	camera.set("limit_bottom", Settings.HEIGHT * Settings.TILESIZE + (3 * Settings.TILESIZE))

func spawnBug(tree: SceneTree):
	# TODO non uniform distribution
	# TODO spawn conditions
	var bugToSpawnId = Data.BUGS.keys().pick_random()
	var bugToSpawn = Data.BUGS[bugToSpawnId]
	var factory = load("%s%s" % [Settings.BUGSCENEPATH, bugToSpawn["scene"]])
	var instance = factory.instantiate()

	instance._init(
		bugToSpawnId,
		bugToSpawn["name"],
		bugToSpawn["sprite"],
		bugToSpawn["speed"],
	)
	bugNode.add_child(instance)
	# TODO position outside camera
	instance.global_position = Utils.randomCoordinateVector(Settings.WIDTH, Settings.HEIGHT)
