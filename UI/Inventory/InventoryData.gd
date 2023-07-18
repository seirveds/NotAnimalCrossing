extends Resource
class_name InventoryData

signal inventory_interact(inventory_data: InventoryData, index: int, mouse_button: int)
signal inventory_updated(inventory_data: InventoryData)

var slot_datas: Array

func set_slot_datas(slot_datas: Array):
	self.slot_datas = slot_datas
	return self

func grab_slot_data(index: int):
	var slot_data: SlotData = slot_datas[index]
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		
	return slot_data

func on_slot_clicked(index: int, mouse_button: int):
	inventory_interact.emit(self, index, mouse_button)
