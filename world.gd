extends Node2D

const TILESIZE = 16
const OFFSET = TILESIZE / 2

const TREENODEPATH = "World/ysort/Trees"
const STRUCTURENODEPATH = "World/ysort/Structures"

@onready var riverTileMap = $RiverTileMap
@onready var background = $Background.get_rect()

# Width and height in tiles, not pixels
@onready var mapHeight = floor(background.size.y / TILESIZE)
@onready var mapWidth = floor(background.size.x / TILESIZE)

var usedTiles = []


# Called when the node enters the scene tree for the first time.
func _ready():
	print(mapWidth, "|", mapHeight)
	worldGen()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_text_backspace"):
		clearMap()
		worldGen()
	
func worldGen():
	# Order from hardest to easiest to place
	generateRiver(1)
	generateHouses()
	generateTrees(50)
	
	
func clearMap():
	# TODO generalise this to remove all world node children or smthing
	# Removes trees
	clearNodeChildren(TREENODEPATH)
	clearNodeChildren(STRUCTURENODEPATH)
	# Remove river tiles
	riverTileMap.clear()
	usedTiles = []
	

func generateRiver(riverCount: int = 1):
	const MIN_DOWN_STEPS = 8
	const MAX_DOWN_STEPS = 12
	const MIN_SIDEWAYS_STEPS = 5
	const MAX_SIDEWAYS_STEPS = 10
	const WIDTH = 3
	
	for rivers in riverCount:
		var riverCells = []
		# For now always start river in middle
		var currentCell = Vector2(floor(mapWidth / 2), -1)
		riverCells.append(currentCell)
		
		# Keep track of amount of iterations, use this in deciding
		# wether to go down or sideways
		var stepCount = 0
		# Used to stop while loop when river reached bottom of map
		var bottomReached = false
		
		while not bottomReached:
			var stepsToTake = 0
			var updateVector = Vector2.ZERO
			
			if stepCount % 2:
				# Sideways
				stepsToTake = randi_range(MIN_SIDEWAYS_STEPS, MAX_SIDEWAYS_STEPS)
				if randf() < .5:
					updateVector = Vector2.LEFT
				else:
					updateVector = Vector2.RIGHT
			else:
				# Down
				stepsToTake = randi_range(MIN_DOWN_STEPS, MAX_DOWN_STEPS)
				updateVector = Vector2.DOWN
				
			for i in range(stepsToTake):
				if (currentCell + updateVector).y >= mapHeight:
					bottomReached = true
				elif (
					(currentCell + updateVector).x < mapWidth - 1 - WIDTH and
					(currentCell + updateVector).x > 1 + WIDTH
				):
					currentCell += updateVector
					riverCells.append(currentCell)
					
					# Works for both even and odd widths because of flooring division float results
					# and adding WIDTH % 2 to offset exclusive range max value
					for x in range(currentCell.x - (WIDTH / 2), currentCell.x + (WIDTH / 2) + (WIDTH % 2)):
						for y in range(currentCell.y - (WIDTH / 2), currentCell.y + (WIDTH / 2) + (WIDTH % 2)):
							riverCells.append(Vector2(x, y))
			
			stepCount += 1
			
		riverTileMap.set_cells_terrain_connect(0, riverCells, 0, 0)
		usedTiles.append_array(riverCells)


func generateTrees(n: int = 10):
	var treesNode = get_tree().get_root().get_node(TREENODEPATH)
	var TreeFactory = load("res://World/RandomTree.tscn")
	
	var succesfulPlacements = 0
	while succesfulPlacements < n:
		var newTreeCoordinates = randomCoordinateVector()
		var newTreeTileCoordinates = coordinateToTile(newTreeCoordinates)
		
		# We dont want to place a tree if there is a river tile or other
		# tree in the tiles around. Use computationally expensive nested loop
		# to make sure the tiles around the potential new position are free
		if borderTilesFree(newTreeTileCoordinates):
			var tree = TreeFactory.instantiate()
			treesNode.add_child(tree)
			tree.global_position = newTreeCoordinates
			
			succesfulPlacements += 1
			usedTiles.append(newTreeTileCoordinates)


func generateHouses(n: int = 3):
	# Amount of tiles to keep free around center of house
	const BORDERSIZE = 2
	
	var structuresNode = get_tree().get_root().get_node(STRUCTURENODEPATH)
	var HouseFactory = load("res://World/House.tscn")
	
	for i in range(n):
		while true:
			var position = randomCoordinateVector(5)
			var tilePosition = coordinateToTile(position)
			if borderTilesFree(tilePosition, BORDERSIZE):
				var house = HouseFactory.instantiate()
				structuresNode.add_child(house)
				house.global_position = position

				house.get_node("Sprite").set("frame", i)
				usedTiles.append_array(getBorderingTiles(tilePosition, BORDERSIZE))
				
				break


func spawnPlayer():
	pass

#############
# Utilities #
#############
func randomCoordinateVector(padding: int = 2) -> Vector2:
	# Exclude padding border tiles
	var tileCoordinates = Vector2(
		randi_range(padding, mapWidth - padding),
		randi_range(padding, mapHeight - padding)
	)
	# Transform tile coordinates to pixel coordinates of center of tile
	return tileToCoordinate(tileCoordinates)

func tileToCoordinate(tile: Vector2) -> Vector2:
	# Convert tile coordinates to pixel coordinates
	# Pixel coordinates are center of the tile
	# Vector2(0, 0) -> Vector2(8, 8)
	return ((tile + Vector2.ONE) * TILESIZE) - Vector2(OFFSET, OFFSET)
	
func coordinateToTile(coordinates: Vector2) -> Vector2:
	# Convert pixel coordinates to tile coordinates
	# Vector(7, 1) -> Vector(0, 0)
	return floor(coordinates / float(TILESIZE))

func getBorderingTiles(tile: Vector2, borderSize: int = 1) -> Array:
	var borderingTiles = []
	for x in range(tile.x - borderSize, tile.x + borderSize + 1):
		for y in range(tile.y - borderSize, tile.y + borderSize + 1):
			borderingTiles.append(Vector2(x, y))
	return borderingTiles

func borderTilesFree(tile: Vector2, borderSize: int = 1) -> bool:
	# Given tile coordinates, check if cells around tile are free
	for borderTile in getBorderingTiles(tile, borderSize):
		if borderTile in usedTiles:
			return false
	return true
	
func clearNodeChildren(nodePath: String):
	var node = get_tree().get_root().get_node(nodePath)
	for n in node.get_children():
		n.queue_free()
