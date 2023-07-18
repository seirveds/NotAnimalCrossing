extends PanelContainer

@onready var texture_rect = $MarginContainer/TextureRect
@onready var quantity = $Quantity

signal slot_clicked(index: int, mouse_button: int)

func set_slot_data(slot_data: SlotData):
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.texture
	tooltip_text = item_data.name  # TODO description?
	
	if slot_data.quantity > 1:
		quantity.text = slot_data.quantity
		quantity.show()


func _on_gui_input(event):
	if event is InputEventMouseButton \
			and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT] \
			and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)
