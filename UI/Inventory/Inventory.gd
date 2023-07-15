extends PanelContainer

const Slot = preload("res://UI/Inventory/Slot.tscn")

@onready var item_grid = $MarginContainer/ItemGrid

func set_inventory_data(inventory_data: InventoryData):
	fill_item_grid(inventory_data.slot_data)

func fill_item_grid(slot_datas: Array):
	for child in item_grid.get_children():
		child.queue_free()
		
	for slot_data in slot_datas:
		var slot = Slot.instantiate()
		item_grid.add_child(slot)
		
		if slot_data:
			slot.set_slot_data(slot_data)