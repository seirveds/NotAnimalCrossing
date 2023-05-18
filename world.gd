extends Node2D

# Width and height in pixels
@export var width = 800
@export var height = 450

# RNG seed
@export var randomSeed = 1337

# Dependent on tilemap size
const TILESIZE = 16
const OFFSET = TILESIZE / 2

# Nodes we place objects in during generation
const TREENODEPATH = "World/ysort/Trees"
const FLOWERNODEPATH = "World/ysort/Flowers"
const STRUCTURENODEPATH = "World/ysort/Structures"

# Tilemaps
@onready var riverTileMap = $RiverTileMap
@onready var cliffTileMap = $CliffTileMap

# Width and height in tiles, not pixels
@onready var mapHeight = floor(height / TILESIZE)
@onready var mapWidth = floor(width / TILESIZE)

@onready var camera = $ysort/Alex/Camera2D

# World generation constants
# y height of beach, must be > 2
const BEACHSIZE = 4

# Keep track of tiles used so we dont add nodes on top of eachother
var usedTiles = []


# Called when the node enters the scene tree for the first time.
func _ready():
	seed(randomSeed)
	setCameraLimits()
	print(mapWidth, "|", mapHeight)
	worldGen()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_text_backspace"):
		clearMap()
		worldGen()


func setCameraLimits():
	camera.set("limit_left", 0)
	camera.set("limit_top", 0)
	camera.set("limit_right", width)
	camera.set("limit_bottom", height + (3 * TILESIZE))

	
func worldGen():
	# Order from hardest to easiest to place
	# Tilemap placement
	placeGrass()
	placeBeach()
	placeCliffs()
	generateRiver(1)
	generatePonds(1)
	
	# Node placement
	generateHouses()
	generateTrees(30)
	generateFlowers(80)
	
	
func clearMap():
	# TODO generalise this to remove all world node children or smthing
	# Removes placeable nodes
	clearNodeChildren(TREENODEPATH)
	clearNodeChildren(STRUCTURENODEPATH)
	clearNodeChildren(FLOWERNODEPATH)
	# Remove river tiles
	riverTileMap.clear()
	usedTiles = []
	

func placeGrass():
	const GRASSTILEPROBAS = [0, 0, 0, 0, 0, 0, 0, 0, 1, 2]
	for x in range(mapWidth):
		for y in range(mapHeight - BEACHSIZE):
			riverTileMap.set_cell(
				0,  # Layer
				Vector2i(x, y),  # Coords
				2,  # Source ID
				Vector2i(GRASSTILEPROBAS.pick_random(), 0)  # Atlas coords
			)


func placeBeach():
	# Code to place bottom BEACHSIZE rows of tiles

	# Grass and end tile underneath cliff tiles on bottom sides
	for x in [0, mapWidth - 1]:
		for y in range(mapHeight - BEACHSIZE, mapHeight):
			var atlasCoords = Vector2i(0, 0)
			if y == mapHeight - 1:
				atlasCoords = Vector2i(1, 4)
			riverTileMap.set_cell(0, Vector2i(x, y), 2, atlasCoords)

	# Rest of beach
	for y in range(mapHeight - BEACHSIZE, mapHeight):
		var atlasY = 2
		# Transition tiles to grass and ocean
		if y == mapHeight - BEACHSIZE:
			atlasY = 1
		elif y == mapHeight - 1:
			atlasY = 3

		for x in range(1, mapWidth - 1):
			var atlasX = 1
			if x == 1:
				atlasX = 0
			elif x == mapWidth - 2:
				atlasX = 2
			riverTileMap.set_cell(
				0,  # Layer
				Vector2i(x, y),  # Coords
				2,  # SourceId
				Vector2i(atlasX, atlasY),  # Atlas coords
			)
	
	# Sea tiles
	for x in range(mapWidth):
		for y in range(mapHeight, mapHeight + 4):
			riverTileMap.set_cell(0, Vector2i(x, y), 2, Vector2i(2, 4))


func placeCliffs():
	# Mapheight - 2 because bottom most corners will be tile
	# from other tilemap
	var corners = [
		[Vector2i(0, 0), Vector2i(4, 1)],  # Top left
		[Vector2i(mapWidth - 1, 0), Vector2i(3, 1)],  # Top right
		[Vector2i(0, mapHeight - 2), Vector2i(2, 2)],  # Bottom left
		[Vector2i(mapWidth - 1, mapHeight - 2), Vector2i(0, 2)],  # Bottom right
	]
	
	var sides = []
	for y in range(1, mapHeight - 2):
		sides.append_array([
			[Vector2i(0, y), Vector2i(2, 1)],
			[Vector2i(mapWidth - 1, y), Vector2i(0, 1)]
		])
		
	var top = []
	for x in range(1, mapWidth - 1):
		top.append([Vector2i(x, 0), Vector2i(1, 2)])

	for coordinates in corners + sides + top:
		cliffTileMap.set_cell(
			0,  # Layer
			coordinates[0],  # Coords
			0,  # Source ID
			coordinates[1],  # Atlas coords
		)
	
	# Remove cliffs where river enters map
	# TODO start of river is hardcoded, change this when
	# river generation code changes
	var middle = Vector2i(floor(mapWidth / 2), 0)
	for x in range(middle.x - 1, middle.x + 2):
		cliffTileMap.erase_cell(0, Vector2i(x, 0))
	
	# Manually set 2 corner tiles
	cliffTileMap.set_cell(0, Vector2i(middle.x - 2, 0), 0, Vector2i(2, 2))
	cliffTileMap.set_cell(0, Vector2i(middle.x + 2, 0), 0, Vector2i(0, 2))


func generateRiver(riverCount: int = 1):
	# Horrible river generation code
	# Placeholder for actually smart river generation
	const MIN_DOWN_STEPS = 6
	const MAX_DOWN_STEPS = 10
	const MIN_SIDEWAYS_STEPS = 5
	const MAX_SIDEWAYS_STEPS = 10
	const BEACHPADDING = 3
	
	# Cannot change this yet
	const WIDTH = 3
	
	for rivers in riverCount:
		var riverCells = []
		# For now always start river in middle
		var currentCell = Vector2i(floor(mapWidth / 2), -1)
		riverCells.append(currentCell)
		
		# Keep track of amount of iterations, use this in deciding
		# wether to go down or sideways
		var stepCount = 0
		# Used to stop while loop when river reached bottom of map
		var finalStretch = false
		
		var bridgeCells = []
		# Cells of the middle of the river, before adding padding
		# Used for bridge placement and river end tiles
		var coreCells = []
		
		while not finalStretch:
			var stepsToTake = 0
			var updateVector = Vector2i.ZERO
			
			# Keep track of cells added in current iteration
			var stepCells = []
			
			if stepCount % 2:
				# Sideways
				stepsToTake = randi_range(MIN_SIDEWAYS_STEPS, MAX_SIDEWAYS_STEPS)
				if randf() < .5:
					updateVector = Vector2i.LEFT
				else:
					updateVector = Vector2i.RIGHT
			else:
				# Down
				stepsToTake = randi_range(MIN_DOWN_STEPS, MAX_DOWN_STEPS)
				updateVector = Vector2i.DOWN
				
			for i in range(stepsToTake):
				if (currentCell + updateVector).y >= mapHeight - BEACHSIZE - BEACHPADDING:
					finalStretch = true
				elif (
					(currentCell + updateVector).x < mapWidth - 1 - WIDTH and
					(currentCell + updateVector).x > 1 + WIDTH
				):
					currentCell += updateVector
					riverCells.append(currentCell)
					coreCells.append(currentCell)
					stepCells.append(currentCell)
					
					# Works for both even and odd widths because of flooring division float results
					# and adding WIDTH % 2 to offset exclusive range max value
					for x in range(currentCell.x - (WIDTH / 2), currentCell.x + (WIDTH / 2) + (WIDTH % 2)):
						for y in range(currentCell.y - (WIDTH / 2), currentCell.y + (WIDTH / 2) + (WIDTH % 2)):
							riverCells.append(Vector2i(x, y))
							
			# BRIDGE
			if stepCount == 2:
				var middle = (stepsToTake / 2) - 1
				# Take 3 cells from the middle as bridge is 3 tiles 'high'
				for value in stepCells.slice(middle - 1, middle + 2):
					for x in range(value.x - (WIDTH / 2), value.x + (WIDTH / 2) + 1):
						bridgeCells.append(Vector2i(x, value.y))
			
			stepCount += 1

		riverTileMap.set_cells_terrain_connect(0, riverCells, 0, 0)
			
		# River end, meeting with sea
		var finalCoreCell = coreCells[-1]

		# River mouth tiles that follow autotile rules
		var normalTiles = []
		# First + 1 for exclusive upper limit, second + 1 are tiles we remove
		# to get rid of autotile river ending
		for y in range(finalCoreCell.y, finalCoreCell.y + BEACHPADDING + BEACHSIZE + 1):
			for x in range(finalCoreCell.x - 1, finalCoreCell.x + 2):
				normalTiles.append(Vector2i(x, y))
				usedTiles.append(Vector2i(x, y))
		
		# RIVER MOUTH
		# Use autotile placer to finish river until sea starts + 1 layer
		# + 1 layer is deleted to remove the autotile river end
		riverTileMap.set_cells_terrain_connect(0, normalTiles, 0, 0)
		
		# Remove autotile river end
		var atlasCoords = [Vector2i(6, 2), Vector2i(1, 1), Vector2i(5, 2)]
		for coords in zip(normalTiles.slice(-3), atlasCoords):
			riverTileMap.set_cell(0, coords[0], 0, coords[1])
			
		# From middle of end of river work back up to add grass border
		# to river on sand tiles
		var finalMiddleTile = normalTiles[-2]
		for x in [finalMiddleTile.x - 2, finalMiddleTile.x + 2]:
			var atlasX = 2
			if x == finalMiddleTile.x + 2:
				atlasX = 0
			var yMin = finalMiddleTile.y - BEACHSIZE + 1
			var yMax = finalMiddleTile.y + 1
			for y in range(yMin, yMax):
				var atlasY = 2
				if y == yMin:
					atlasY = 1
				elif y == yMax - 1:
					atlasY = 3
				riverTileMap.set_cell(0, Vector2i(x, y), 2, Vector2i(atlasX, atlasY))
				usedTiles.append(Vector2i(x, y))
			
		# Erase after set_cells_terrain_connect to prevent autotile from
		# patching the river before and after bridge
		for cell in bridgeCells:
			riverTileMap.erase_cell(0, cell)
		riverTileMap.set_cell(
			0,  # Layer
			bridgeCells[bridgeCells.size() / 2],  # Map coords
			1,  # Terrain id
			Vector2i(0, 0)  # Atlas coords
		)
		usedTiles.append_array(riverCells)


func generatePonds(n: int = 1):
	for i in range(n):
		while true:
			# Big padding, dont want pond to close to edge of map
			var newCoordinates = randomCoordinateVector(8)
			var newTileCoordinates = coordinateToTile(newCoordinates)
			
			# Big border, dont want pond too close to river
			if borderTilesFree(newTileCoordinates, 5):
				var pondTiles = getBorderingTiles(newTileCoordinates)
				# Pick random corner and add extra 3 by 3 pond area
				# Because of symmetry only top 2 corners are enough
				var corner = pondTiles[[0, 2].pick_random()]
				pondTiles.append_array(getBorderingTiles(corner))
				

				riverTileMap.set_cells_terrain_connect(0, pondTiles, 0, 0)
				usedTiles.append_array(pondTiles)
				break


func generateTrees(n: int = 10):
	placeAtRandomPosition(
		TREENODEPATH,
		"res://World/RandomTree.tscn",
		n,
		1
	)


func generateFlowers(n: int = 100):
	placeAtRandomPosition(
		FLOWERNODEPATH,
		"res://World/PickableFlower.tscn",
		n,
		0
	)


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
	
	
func placeAtRandomPosition(
		targetNodePath: String,
		resourcePath: String,
		amount: int,
		border: int = 1,
		excludeBeach: bool = true
	):
	var targetNode = get_tree().get_root().get_node(targetNodePath)
	var factory = load(resourcePath)
	
	var succesfulPlacements = 0
	while succesfulPlacements < amount:
		var newCoordinates = randomCoordinateVector()
		var newTileCoordinates = coordinateToTile(newCoordinates)
		
		# We dont want to place a tree if there is a river tile or other
		# tree in the tiles around. Use computationally expensive nested loop
		# to make sure the tiles around the potential new position are free
		var borderFree = borderTilesFree(newTileCoordinates, border)
		
		# If excludeBeach flag set to true dont place stuff on beach tiles
		var notOnBeach = false
		if excludeBeach:
			notOnBeach = newTileCoordinates.y < (mapHeight - BEACHSIZE)
		else:
			notOnBeach = true
		if borderFree and notOnBeach:
			var instance = factory.instantiate()
			targetNode.add_child(instance)
			instance.global_position = newCoordinates
			
			succesfulPlacements += 1
			usedTiles.append(newTileCoordinates)

#############
# Utilities #
#############
func randomCoordinateVector(padding: int = 2) -> Vector2i:
	# Exclude padding border tiles
	var tileCoordinates = Vector2i(
		randi_range(padding, mapWidth - padding - 1),
		randi_range(padding, mapHeight - padding - 1)
	)
	# Transform tile coordinates to pixel coordinates of center of tile
	return tileToCoordinate(tileCoordinates)

func tileToCoordinate(tile: Vector2i) -> Vector2i:
	# Convert tile coordinates to pixel coordinates
	# Pixel coordinates are center of the tile
	# Vector2i(0, 0) -> Vector2i(8, 8)
	return ((tile + Vector2i.ONE) * TILESIZE) - Vector2i(OFFSET, OFFSET)
	
func coordinateToTile(coordinates: Vector2i) -> Vector2i:
	# Convert pixel coordinates to tile coordinates
	# Vector(7, 1) -> Vector(0, 0)
	return floor(coordinates / float(TILESIZE))

func getBorderingTiles(tile: Vector2i, borderSize: int = 1) -> Array:
	var borderingTiles = []
	for x in range(tile.x - borderSize, tile.x + borderSize + 1):
		for y in range(tile.y - borderSize, tile.y + borderSize + 1):
			borderingTiles.append(Vector2i(x, y))
	return borderingTiles

func borderTilesFree(tile: Vector2i, borderSize: int = 1) -> bool:
	# Given tile coordinates, check if cells around tile are free
	for borderTile in getBorderingTiles(tile, borderSize):
		if borderTile in usedTiles:
			return false
	return true
	
func clearNodeChildren(nodePath: String):
	var node = get_tree().get_root().get_node(nodePath)
	for n in node.get_children():
		n.queue_free()

func zip(arr1: Array, arr2: Array) -> Array:
	# Works like python's zip
	# arr1 and arr2 must be same length
	var out = []
	for i in range(arr1.size()):
		out.append([arr1[i], arr2[i]])
	return out
