extends Node
class_name Settings

# Tilemap size
const TILESIZE = 16
const OFFSET = TILESIZE / 2

# Map size
# Width and height in pixels
const WIDTH = 800
const HEIGHT = 450

# Width and height in tiles
# Because of const manually calculate WIDTH or HEIGHT / TILESIZE
const MAPWIDTH = 50
const MAPHEIGHT = 28

# Location of nodes in global tree
const TREENODEPATH = "World/ysort/Trees"
const FLOWERNODEPATH = "World/ysort/Flowers"
const STRUCTURENODEPATH = "World/ysort/Structures"
