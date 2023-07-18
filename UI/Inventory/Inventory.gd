extends PanelContainer

const Slot = preload("res://UI/Inventory/Slot.tscn")

@onready var item_grid = $MarginContainer/ItemGrid


func set_inventory_data(inventory_data: InventoryData):
	inventory_data.inventory_updated.connect(fill_item_grid)
	fill_item_grid(inventory_data)

func fill_item_grid(inventory_data: InventoryData):
	for child in item_grid.get_children():
		child.queue_free()
		
	for slot_data in inventory_data.slot_datas:
		var slot = Slot.instantiate()
		item_grid.add_child(slot)
		
		# When the slot emits slot_clicked, we want to call the 
		# function inventory_data.on_slot_clicked
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)
