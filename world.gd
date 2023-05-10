extends Node2D

const TILESIZE = 16
const OFFSET = TILESIZE / 2

@onready var riverTileMap = $RiverTileMap
@onready var background = $Background.get_rect()

# Width and height in tiles, not pixels
@onready var mapHeight = floor(background.size.y / TILESIZE)
@onready var mapWidth = floor(background.size.x / TILESIZE)

var usedTiles = []


# Called when the node enters the scene tree for the first time.
func _ready():
	print(mapWidth, "|", mapHeight)
	generateRiver()
	generateTrees(50)
	

func generateRiver():
	const MIN_DOWN_STEPS = 5
	const MAX_DOWN_STEPS = 10
	const MIN_SIDEWAYS_STEPS = 5
	const MAX_SIDEWAYS_STEPS = 10
	const WIDTH = 3
	
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
	var treesNode = get_tree().get_root().get_node("World/ysort/Trees")
	var TreeFactory = load("res://World/Tree.tscn")
	
	var succesfulPlacements = 0
	while succesfulPlacements < n:
		var newTreeCoordinates = randomCoordinateVector()
		var newTreeTileCoordinates = coordinateToTile(newTreeCoordinates)
		
		# We dont want to place a tree if there is a river tile or other
		# tree in the tiles around. Use computationally expensive nested loop
		# to make sure the tiles around the potential new position are free
		var borderTilesFree = []
		for x in range(newTreeTileCoordinates.x - 1, newTreeTileCoordinates.x + 2):
			for y in range(newTreeTileCoordinates.y - 1, newTreeTileCoordinates.y + 2):
				borderTilesFree.append(Vector2(x, y) not in usedTiles)
		
		if not false in borderTilesFree:
			var tree = TreeFactory.instantiate()
			treesNode.add_child(tree)
			tree.global_position = newTreeCoordinates
			
			succesfulPlacements += 1
			usedTiles.append(newTreeTileCoordinates)

func spawnPlayer():
	pass

func randomCoordinateVector() -> Vector2:
	# Exclude border tiles
	var tileCoordinates = Vector2(
		randi_range(2, mapWidth - 2),
		randi_range(2, mapHeight - 2)
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

