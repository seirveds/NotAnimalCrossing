extends Node
class_name Settings

# Tilemap size
const TILESIZE = 16
const OFFSET = TILESIZE / 2

# Map size
# Width and height in tiles
const WIDTH = 50
const HEIGHT = 28

const MAXBUGS = 10
const MAXFISH = 10

const DAYLENGTH = 1 * 60  # In seconds


# Location of nodes in global tree
const NODESROOT = "World/ysort/"
const TREENODEPATH = NODESROOT + "Trees"
const FLOWERNODEPATH = NODESROOT + "Flowers"
const STRUCTURENODEPATH = NODESROOT + "Structures"
const BUGSNODEPATH = NODESROOT + "Bugs"
