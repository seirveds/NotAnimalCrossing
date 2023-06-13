extends ColorRect

@onready var item_icon = $ItemIcon
@onready var item_quantity = $ItemQuantity
@onready var items = Data.ITEMS

func display_item(iid: String):
	if iid in items.keys():
		var item = items[iid]
		item_icon.texture = load("%s%s" % [Settings.BUGTEXTUREPATH, item["sprite"]])
		# TODO
		item_quantity.text = ""
	else:
		item_icon.texture = null
		item_quantity.text = ""
