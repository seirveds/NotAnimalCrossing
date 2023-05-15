extends Node2D

# Width and height in pixels
@export var width = 800
@export var height = 450

const TILESIZE = 16
const OFFSET = TILESIZE / 2

const TREENODEPATH = "World/ysort/Trees"
const FLOWERNODEPATH = "World/ysort/Flowers"
const STRUCTURENODEPATH = "World/ysort/Structures"

@onready var riverTileMap = $RiverTileMap
@onready var cliffTileMap = $CliffTileMap
@onready var background = $Background.get_rect()

# Width and height in tiles, not pixels
@onready var mapHeight = floor(height / TILESIZE)
@onready var mapWidth = floor(width / TILESIZE)

var usedTiles = []


# Called when the node enters the scene tree for the first time.
func _ready():
	print(mapWidth, "|", mapHeight)
	worldGen()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_text_backspace"):
		clearMap()
		worldGen()
		
func placeGrass():
	const GRASSTILEPROBAS = [0, 0, 0, 0, 0, 0, 0, 0, 1, 2]
	for x in range(mapWidth):
		for y in range(mapHeight):
			riverTileMap.set_cell(
				0,  # Layer
				Vector2i(x, y),  # Coords
				2,  # Source ID
				Vector2i(GRASSTILEPROBAS.pick_random(), 0)  # Atlas coords
			)
			
func placeCliffs():
	var corners = [
		[Vector2i(0, 0), Vector2i(4, 1)],  # Top left
		[Vector2i(mapWidth - 1, 0), Vector2i(3, 1)],  # Top right
		[Vector2i(0, mapHeight - 1), Vector2i(2, 2)],  # Bottom left
		[Vector2i(mapWidth - 1, mapHeight - 1), Vector2i(0, 2)],  # Bottom right
	]
	
	var sides = []
	for y in range(1, mapHeight - 1):
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
	
	
func placeBeach():
	pass
	
	
func worldGen():
	# Order from hardest to easiest to place
	# Tilemap placement
	placeGrass()
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
		
		var bridgeCells = []
		
		while not bottomReached:
			var stepsToTake = 0
			var updateVector = Vector2.ZERO
			# Cells of the middle of the river, before adding padding
			# Used for bridge placement
			var coreCells = []
			
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
					coreCells.append(currentCell)
					
					# Works for both even and odd widths because of flooring division float results
					# and adding WIDTH % 2 to offset exclusive range max value
					for x in range(currentCell.x - (WIDTH / 2), currentCell.x + (WIDTH / 2) + (WIDTH % 2)):
						for y in range(currentCell.y - (WIDTH / 2), currentCell.y + (WIDTH / 2) + (WIDTH % 2)):
							riverCells.append(Vector2(x, y))
							
			if stepCount == 2:
				var middle = stepsToTake / 2
				# Take 3 cells from the middle as bridge is 3 tiles 'high'
				for value in coreCells.slice(middle - 1, middle + 2):
					for x in range(value.x - (WIDTH / 2), value.x + (WIDTH / 2) + 1):
						bridgeCells.append(Vector2(x, value.y))
			
			stepCount += 1
			
		riverTileMap.set_cells_terrain_connect(0, riverCells, 0, 0)
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
	
	
func placeAtRandomPosition(targetNodePath: String, resourcePath: String, amount: int, border: int = 1):
	var targetNode = get_tree().get_root().get_node(targetNodePath)
	var factory = load(resourcePath)
	
	var succesfulPlacements = 0
	while succesfulPlacements < amount:
		var newCoordinates = randomCoordinateVector()
		var newTileCoordinates = coordinateToTile(newCoordinates)
		
		# We dont want to place a tree if there is a river tile or other
		# tree in the tiles around. Use computationally expensive nested loop
		# to make sure the tiles around the potential new position are free
		if borderTilesFree(newTileCoordinates, border):
			var instance = factory.instantiate()
			targetNode.add_child(instance)
			instance.global_position = newCoordinates
			
			succesfulPlacements += 1
			usedTiles.append(newTileCoordinates)

#############
# Utilities #
#############
func randomCoordinateVector(padding: int = 2) -> Vector2:
	# Exclude padding border tiles
	var tileCoordinates = Vector2(
		randi_range(padding, mapWidth - padding - 1),
		randi_range(padding, mapHeight - padding - 1)
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
