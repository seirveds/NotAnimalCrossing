extends Node
class_name PlayerInventory

const ROWS = 3
const COLS = 5
const SLOTS = ROWS * COLS
const PADDING = 4

signal inventoryChanged

func _ready():
	for i in range(SLOTS):
		Globals.inventory.append(null)


#########
# Utils #
#########
static func add_item(iid: String):
	""" Adds item to first available inventory slot. """
	for i in range(SLOTS):
		if Globals.inventory[i] == null:
			set_item(i, iid)
			return true
	return false
	
static func set_item(index: int, iid: String):
	var prev_item = Globals.inventory[index]
	Globals.inventory[index] = iid
	return prev_item
	
static func remove_item(index: int):
	Globals.inventory[index] = null
