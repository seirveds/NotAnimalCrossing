extends Node2D

const TILESIZE = 16
const OFFSET = TILESIZE / 2

@onready var riverTileMap = $RiverTileMap
@onready var background = $Background.get_rect()

@onready var mapHeight = floor(background.size.y / TILESIZE)
@onready var mapWidth = floor(background.size.x / TILESIZE)


# Called when the node enters the scene tree for the first time.
func _ready():
	print(mapWidth, "|", mapHeight)
	generateTrees(50)
	generateRiver()
	


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
	
	var stepCount = 0
	
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
			if (currentCell + updateVector).y > mapHeight:
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


func generateTrees(n: int = 10):
	var treesNode = get_tree().get_root().get_node("World/ysort/Trees")#.current_scene

	var TreeFactory = load("res://World/Tree.tscn")
	
	for i in range(n):
		var tree = TreeFactory.instantiate()
		treesNode.add_child(tree)
		tree.global_position = randomCoordinateVector()


func spawnPlayer():
	pass

func randomCoordinateVector():
	# Exclude border tiles
	var tileCoordinates = Vector2i(
		randi_range(2, mapWidth - 2),
		randi_range(2, mapHeight - 2)
	)
	# Transform tile coordinates to pixel coordinates
	# Offset is used to go in middle of tile instead of corner
	return (tileCoordinates * TILESIZE) - Vector2i(OFFSET, OFFSET)
