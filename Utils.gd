extends Node
class_name Utils

static func randomCoordinateVector(
		mapWidth: int,
		mapHeight: int,
		padding: int = 2,
	) -> Vector2i:
	# Gene
	var tileCoordinates = Vector2i(
		randi_range(padding, mapWidth - padding - 1),
		randi_range(padding, mapHeight - padding - 1)
	)
	# Transform tile coordinates to pixel coordinates of center of tile
	return tileToCoordinate(tileCoordinates)

static func tileToCoordinate(tile: Vector2i) -> Vector2i:
	# Convert tile coordinates to pixel coordinates
	# Pixel coordinates are center of the tile
	# Vector2i(0, 0) -> Vector2i(8, 8)
	return ((tile + Vector2i.ONE) * Settings.TILESIZE) - Vector2i(Settings.OFFSET, Settings.OFFSET)
	
static func coordinateToTile(coordinates: Vector2i) -> Vector2i:
	# Convert pixel coordinates to tile coordinates
	# Vector(7, 1) -> Vector(0, 0)
	return floor(coordinates / float(Settings.TILESIZE))

static func getBorderingTiles(tile: Vector2i, borderSize: int = 1) -> Array:
	var borderingTiles = []
	for x in range(tile.x - borderSize, tile.x + borderSize + 1):
		for y in range(tile.y - borderSize, tile.y + borderSize + 1):
			borderingTiles.append(Vector2i(x, y))
	return borderingTiles

static func borderTilesFree(
		tile: Vector2i,
		borderSize: int = 1
	) -> bool:
	# Given tile coordinates, check if cells around tile are free
	for borderTile in getBorderingTiles(tile, borderSize):
		if borderTile in Globals.usedTiles:
			return false
	return true
	
static func clearNodeChildren(tree: SceneTree, nodePath: String):
	var node = tree.get_root().get_node(nodePath)
	for n in node.get_children():
		n.queue_free()

static func zip(arr1: Array, arr2: Array) -> Array:
	# Works like python's zip method
	assert(arr1.size() == arr2.size())
	var out = []
	for i in range(arr1.size()):
		out.append([arr1[i], arr2[i]])
	return out
