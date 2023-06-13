extends GridContainer

@onready var item_slot = preload("res://UI/ItemSlot.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(PlayerInventory.SLOTS):
		var item_slot_instance = item_slot.instantiate()
		add_child(item_slot_instance)
		item_slot_instance.display_item(["101", "102", "103", "104", "105", ""].pick_random())

	await(get_tree())
	position = (get_viewport_rect().size - size) / 2
	hide()

