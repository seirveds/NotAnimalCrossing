extends Resource
class_name SlotData

const MAX_STACK: int = 10

var item_data: ItemData
var quantity: int = 1

func init(item_data: ItemData, quantity: int = 1):
	self.item_data = item_data
	self.quantity = quantity
	# Return self so we can use resource.new().init() on one line
	return self
