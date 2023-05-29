extends Node
class_name WorldGen

############
# Settings #
############

# World generation constants
# y height of beach, must be > 2
const BEACHSIZE = 4
# Grass tile usage probability
# Number corresponds to x coord in tilemap
const GRASSTILEPROBAS = [0, 0, 0, 0, 0, 0, 0, 0, 1, 2]

# River parameters
const MIN_DOWN_STEPS = 6
const MAX_DOWN_STEPS = 10
const MIN_SIDEWAYS_STEPS = 5
const MAX_SIDEWAYS_STEPS = 10
# Minimum amount of grass tiles to keep between beach
# and horizontal river parts
const BEACHPADDING = 3
# Cannot change this yet
const RIVERWIDTH = 3

# House parameter
# Amount of tiles to keep free around center of house
const HOUSEBORDERSIZE = 2

#############
# Functions #
#############

static func generateWorld(tree: SceneTree, tilemap: TileMap):
	# Order from hardest to easiest to place
	# Tilemap placement
	placeGrass(tilemap)
	placeBeach(tilemap)
	placeCliffs(tilemap)
	generateRiver(tilemap, 1)
	generatePonds(tilemap, 2)
	
	# Node placement
	generateHouses(tree, tilemap)
	generateTrees(tree, tilemap, 30)
	generateFlowers(tree, 80)
	
	
static func clearWorld(tree: SceneTree, tilemap: TileMap):
	# Removes placeable nodes
	# TODO
	var nodesToClear = [
		Settings.TREENODEPATH,
		Settings.STRUCTURENODEPATH,
		Settings.FLOWERNODEPATH
	]
	for node in nodesToClear:
		Utils.clearNodeChildren(tree, node)

	tilemap.clear()
	Globals.usedTiles = []
	

#####################
# Tilemap placement #
#####################

static func placeGrass(tilemap: TileMap):
	for x in range(Settings.WIDTH):
		for y in range(Settings.HEIGHT - BEACHSIZE):
			tilemap.set_cell(
				0,  # Layer
				Vector2i(x, y),  # Coords
				2,  # Source ID
				Vector2i(GRASSTILEPROBAS.pick_random(), 0)  # Atlas coords
			)


static func placeCliffs(tilemap: TileMap):
	# Mapheight - 2 because bottom most corners will be tile
	# from other tilemap
	var corners = [
		[Vector2i(0, 0), Vector2i(4, 1)],  # Top left
		[Vector2i(Settings.WIDTH - 1, 0), Vector2i(3, 1)],  # Top right
		[Vector2i(0, Settings.HEIGHT - 2), Vector2i(2, 2)],  # Bottom left
		[Vector2i(Settings.WIDTH - 1, Settings.HEIGHT - 2), Vector2i(0, 2)],  # Bottom right
	]
	
	var sides = []
	for y in range(1, Settings.HEIGHT - 2):
		sides.append_array([
			[Vector2i(0, y), Vector2i(2, 1)],
			[Vector2i(Settings.WIDTH - 1, y), Vector2i(0, 1)]
		])
		
	var top = []
	for x in range(1, Settings.WIDTH - 1):
		top.append([Vector2i(x, 0), Vector2i(1, 2)])

	for coordPair in corners + sides + top:
		tilemap.set_cell(
			0,  # Layer
			coordPair[0],  # Coords
			3,  # Source ID
			coordPair[1],  # Atlas coords
		)
	
	# Remove cliffs where river enters map
	# TODO start of river is hardcoded, change this when
	# river generation code changes
	var middle = Vector2i(floor(Settings.WIDTH / 2), 0)
	for x in range(middle.x - 1, middle.x + 2):
		tilemap.erase_cell(0, Vector2i(x, 0))
	
	# Manually set 2 corner tiles
	tilemap.set_cell(0, Vector2i(middle.x - 2, 0), 3, Vector2i(2, 2))
	tilemap.set_cell(0, Vector2i(middle.x + 2, 0), 3, Vector2i(0, 2))


static func placeBeach(tilemap: TileMap):
	# Code to place bottom BEACHSIZE rows of tiles

	# Grass and end tile underneath cliff tiles on bottom sides
	for x in [0, Settings.WIDTH - 1]:
		for y in range(Settings.HEIGHT - BEACHSIZE, Settings.HEIGHT):
			var atlasCoords = Vector2i.ZERO
			if y == Settings.HEIGHT - 1:
				atlasCoords = Vector2i(1, 4)
			tilemap.set_cell(0, Vector2i(x, y), 2, atlasCoords)

	# Rest of beach
	for y in range(Settings.HEIGHT - BEACHSIZE, Settings.HEIGHT):
		var atlasY = 2
		# Transition tiles to grass and ocean
		if y == Settings.HEIGHT - BEACHSIZE:
			atlasY = 1
		elif y == Settings.HEIGHT - 1:
			atlasY = 3

		for x in range(1, Settings.WIDTH - 1):
			var atlasX = 1
			if x == 1:
				atlasX = 0
			elif x == Settings.WIDTH - 2:
				atlasX = 2
			tilemap.set_cell(
				0,  # Layer
				Vector2i(x, y),  # Coords
				2,  # SourceId
				Vector2i(atlasX, atlasY),  # Atlas coords
			)
	
	# Sea tiles
	for x in range(Settings.WIDTH):
		for y in range(Settings.HEIGHT, Settings.HEIGHT + 4):
			tilemap.set_cell(0, Vector2i(x, y), 2, Vector2i(2, 4))


static func generateRiver(tilemap: TileMap, riverCount: int = 1):
	# Horrible river generation code
	# Placeholder for actually smart river generation
	
	for rivers in riverCount:
		var riverCells = []
		# For now always start river in middle
		var currentCell = Vector2i(floor(Settings.WIDTH / 2), -1)
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
				if (currentCell + updateVector).y >= Settings.HEIGHT - BEACHSIZE - BEACHPADDING:
					finalStretch = true
				elif (
					(currentCell + updateVector).x < Settings.WIDTH - 1 - RIVERWIDTH and
					(currentCell + updateVector).x > 1 + RIVERWIDTH
				):
					currentCell += updateVector
					riverCells.append(currentCell)
					coreCells.append(currentCell)
					stepCells.append(currentCell)
					
					# Works for both even and odd widths because of flooring division float results
					# and adding WIDTH % 2 to offset exclusive range max value
					for x in range(currentCell.x - (RIVERWIDTH / 2), currentCell.x + (RIVERWIDTH / 2) + (RIVERWIDTH % 2)):
						for y in range(currentCell.y - (RIVERWIDTH / 2), currentCell.y + (RIVERWIDTH / 2) + (RIVERWIDTH % 2)):
							riverCells.append(Vector2i(x, y))
							
			# BRIDGE
			if stepCount == 2:
				var middle = (stepsToTake / 2) - 1
				# Take 3 cells from the middle as bridge is 3 tiles 'high'
				for value in stepCells.slice(middle - 1, middle + 2):
					for x in range(value.x - (RIVERWIDTH / 2), value.x + (RIVERWIDTH / 2) + 1):
						bridgeCells.append(Vector2i(x, value.y))
			
			stepCount += 1

		tilemap.set_cells_terrain_connect(0, riverCells, 0, 0)
			
		# River end, meeting with sea
		var finalCoreCell = coreCells[-1]

		# River mouth tiles that follow autotile rules
		var normalTiles = []
		# First + 1 for exclusive upper limit, second + 1 are tiles we remove
		# to get rid of autotile river ending
		for y in range(finalCoreCell.y, finalCoreCell.y + BEACHPADDING + BEACHSIZE + 1):
			for x in range(finalCoreCell.x - 1, finalCoreCell.x + 2):
				normalTiles.append(Vector2i(x, y))
				Globals.usedTiles.append(Vector2i(x, y))
		
		# RIVER MOUTH
		# Use autotile placer to finish river until sea starts + 1 layer
		# + 1 layer is deleted to remove the autotile river end
		tilemap.set_cells_terrain_connect(0, normalTiles, 0, 0)
		
		# Remove autotile river end
		var atlasCoords = [Vector2i(6, 2), Vector2i(1, 1), Vector2i(5, 2)]
		for coords in Utils.zip(normalTiles.slice(-3), atlasCoords):
			tilemap.set_cell(0, coords[0], 0, coords[1])
			
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
				tilemap.set_cell(0, Vector2i(x, y), 2, Vector2i(atlasX, atlasY))
				Globals.usedTiles.append(Vector2i(x, y))
			
		# Erase after set_cells_terrain_connect to prevent autotile from
		# patching the river before and after bridge
		for cell in bridgeCells:
			tilemap.erase_cell(0, cell)
		tilemap.set_cell(
			0,  # Layer
			bridgeCells[bridgeCells.size() / 2],  # Map coords
			1,  # Terrain id
			Vector2i(0, 0)  # Atlas coords
		)
		Globals.usedTiles.append_array(riverCells)


static func generatePonds(tilemap: TileMap, amount: int = 2):
	for i in range(amount):
		while true:
			# Big padding, dont want pond to close to edge of map
			var newCoordinates = Utils.randomCoordinateVector(Settings.WIDTH, Settings.HEIGHT, 8)
			var newTileCoordinates = Utils.coordinateToTile(newCoordinates)
			
			# Big border, dont want pond too close to river
			if Utils.borderTilesFree(newTileCoordinates, 5):
				var pondTiles = Utils.getBorderingTiles(newTileCoordinates)
				# Pick random corner and add extra 3 by 3 pond area
				# Because of symmetry only top 2 corners are enough
				var corner = pondTiles[[0, 2].pick_random()]
				pondTiles.append_array(Utils.getBorderingTiles(corner))
				

				tilemap.set_cells_terrain_connect(0, pondTiles, 0, 0)
				Globals.usedTiles.append_array(pondTiles)
				break

##################
# Node placement #
##################

static func generateTrees(tree: SceneTree, tilemap: TileMap, amount: int = 10):
	placeAtRandomPosition(
		tree,
		Settings.TREENODEPATH,
		"res://World/Scenes/RandomTree.tscn",
		amount,
		1,  # border
		true,  # excludeBeach
		true,  # removeNavigationTile
		tilemap,
	)


static func generateFlowers(tree: SceneTree, amount: int = 100):
	placeAtRandomPosition(
		tree, 
		Settings.FLOWERNODEPATH,
		"res://World/Scenes/PickableFlower.tscn",
		amount,
		0,  # Border
	)


static func generateHouses(tree: SceneTree, tilemap: TileMap, amount: int = 3):
	var structuresNode = tree.get_root().get_node(Settings.STRUCTURENODEPATH)
	var HouseFactory = load("res://World/Scenes/House.tscn")
	
	for i in range(amount):
		while true:
			var position = Utils.randomCoordinateVector(Settings.WIDTH, Settings.HEIGHT, 5)
			var tilePosition = Utils.coordinateToTile(position)
			if Utils.borderTilesFree(tilePosition, HOUSEBORDERSIZE):
				var house = HouseFactory.instantiate()
				structuresNode.add_child(house)
				house.global_position = position

				house.get_node("Sprite").set("frame", i)
				Globals.usedTiles.append_array(
					Utils.getBorderingTiles(tilePosition, HOUSEBORDERSIZE)
				)
				
				# Remove tiles house placed on from navigation mesh
				for y in range(tilePosition.y - 2, tilePosition.y + 1):
					for x in range(tilePosition.x - 1, tilePosition.x + 2):
						tilemap.set_cell(0, Vector2i(x, y), 2, Vector2i(0, 4))
				
				break


static func spawnPlayer():
	pass


static func placeAtRandomPosition(
		tree: SceneTree,
		targetNodePath: String,
		resourcePath: String,
		amount: int,
		border: int = 1,
		excludeBeach: bool = true,
		removeNavigationTile: bool = false,
		tilemap: TileMap = null,
	):
	var targetNode = tree.get_root().get_node(targetNodePath)
	var factory = load(resourcePath)
	
	var succesfulPlacements = 0
	while succesfulPlacements < amount:
		var newCoordinates = Utils.randomCoordinateVector(Settings.WIDTH, Settings.HEIGHT)
		var newTileCoordinates = Utils.coordinateToTile(newCoordinates)
		
		# We dont want to place a tree if there is a river tile or other
		# tree in the tiles around. Use computationally expensive nested loop
		# to make sure the tiles around the potential new position are free
		var borderFree = Utils.borderTilesFree(newTileCoordinates, border)
		
		# If excludeBeach flag set to true dont place stuff on beach tiles
		var notOnBeach = false
		if excludeBeach:
			notOnBeach = newTileCoordinates.y < (Settings.HEIGHT - BEACHSIZE)
		else:
			notOnBeach = true
		if borderFree and notOnBeach:
			var instance = factory.instantiate()
			targetNode.add_child(instance)
			instance.global_position = newCoordinates
			
			succesfulPlacements += 1
			Globals.usedTiles.append(newTileCoordinates)
			# Very hacky, place identically looking grass tile but without the
			# navigation mesh to make AI path around node
			if removeNavigationTile:
				tilemap.set_cell(0, newTileCoordinates, 2, Vector2i(0, 4))
