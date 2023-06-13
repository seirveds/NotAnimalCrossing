extends Node
class_name PlayerInventory

const ROWS = 3
const COLS = 5
const SLOTS = ROWS * COLS

func _ready():
	for i in range(SLOTS):
		Globals.inventory.append(null)


#########
# Utils #
#########
func set_item(index: int, iid: String):
	var prev_item = Globals.inventory[index]
	Globals.inventory[index] = iid
	return prev_item
	
func remove_item(index: int):
	Globals.inventory[index] = null
