extends Control

@onready var player_inventory = $PlayerInventory

func set_player_inventory_data(inventory_data: InventoryData):
	player_inventory.fill_item_grid(inventory_data.slot_datas)
