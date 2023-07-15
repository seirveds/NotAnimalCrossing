extends Resource
class_name ItemData

var name: String = ""
var description: String = ""
var stackable: bool = false
var value: int = 0
var texture: Texture
var id: int = 0

func init(id: String):
	var item_dict = Data.ITEMS.get(id)
	self.name = item_dict.name
	self.description = "" # TODO
	self.stackable = item_dict.stackable
	self.value = item_dict.value
	self.texture = load("%s%s" % [Settings.TEXTUREPATH, item_dict.texture])
	self.id = int(id)
	# Return self so we can use resource.new().init() on one line
	return self
