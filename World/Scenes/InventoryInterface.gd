extends Control

@onready var player_inventory = $PlayerInventory
@onready var grabbed_slot = $GrabbedSlot

var grabbed_slot_data: SlotData

func _physics_process(delta):
	if grabbed_slot.visible:
		# Small offset to prevent tooltip from showing
		grabbed_slot.global_position = get_global_mouse_position() - Vector2(10, 10)

func set_player_inventory_data(inventory_data: InventoryData):
	inventory_data.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(inventory_data)

func _on_player_toggle_inventory_visibility():
	visible = !visible

func on_inventory_interact(inventory_data: InventoryData, index: int, mouse_button: int):
	match [grabbed_slot_data, mouse_button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)
			
	update_grabbed_slot()
	
func update_grabbed_slot():
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()
	
