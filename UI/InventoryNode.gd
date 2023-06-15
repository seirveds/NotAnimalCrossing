extends Node2D

@onready var item_slot = preload("res://UI/ItemSlot.tscn")

@onready var wrapper = $Wrapper
@onready var items = $Wrapper/ItemsBackground/Items
@onready var items_background = $Wrapper/ItemsBackground
@onready var stats_background = $Wrapper/StatsBackground


# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_setup()
	hide()
	
func toggle_inventory():
	if not visible:
		inventory_update()
		# TODO update
		set_inventory_position()
	visible = !visible

func inventory_setup():
	var pad = PlayerInventory.PADDING
	var items_width = PlayerInventory.COLS * (18 + pad) + pad
	var inventory_height = PlayerInventory.ROWS * (18 + pad) + pad
	items.set("columns", PlayerInventory.COLS)
	
	items.set("theme_override_constants/h_separation", pad)
	items.set("theme_override_constants/v_separation", pad)
	items.set("position", Vector2i(pad, pad))
	
	items_background.set(
		"size",
		Vector2i(
			items_width,
			inventory_height
		)
	)
	
	stats_background.set(
		"size",
		Vector2i(
			stats_background.size.x,
			inventory_height
		)
	)

func inventory_update():
	Utils.removeNodeChildren(items)
	for item_id in Globals.inventory:
		var item_slot_instance = item_slot.instantiate()
		items.add_child(item_slot_instance)
		item_slot_instance.display_item(item_id)

func set_inventory_position():
	position = Vector2i(100, 50)
