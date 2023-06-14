extends Node2D

@onready var item_slot = preload("res://UI/ItemSlot.tscn")
@onready var container = $Inventory
@onready var background = $Background


# Called when the node enters the scene tree for the first time.
func _ready():
	position_setup()
	for i in range(PlayerInventory.SLOTS):
		var item_slot_instance = item_slot.instantiate()
		container.add_child(item_slot_instance)
		item_slot_instance.display_item(["101", "102", "103", "104", "105", ""].pick_random())

	await(get_tree())
	position = (container.get_viewport_rect().size - container.size) / 2
	hide()

func position_setup():
	var pad = PlayerInventory.PADDING
	container.set("columns", PlayerInventory.COLS)
	
	container.set("theme_override_constants/h_separation", pad)
	container.set("theme_override_constants/v_separation", pad)
	container.set("position", Vector2i(pad, pad))
	
	background.set("size", Vector2i(PlayerInventory.COLS * (18 + pad) + pad, PlayerInventory.ROWS * (18 + pad) + pad))

