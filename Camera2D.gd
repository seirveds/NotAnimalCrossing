extends Camera2D

@onready var world = get_tree().get_root().get_node("World")


# Called when the node enters the scene tree for the first time.
func _ready():
	print(world.get("Width"), world.get("Height"))
