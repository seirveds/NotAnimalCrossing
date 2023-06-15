extends Node

@onready var popup = get_tree().get_root().get_node(Settings.UINODEPATH).get_node("InteractionPopup")

func catch(instance):
	var catch_succesful = PlayerInventory.add_item(instance.id)
	if catch_succesful:
		instance.queue_free()
		popup.open_with_text("Caught %s" % instance.name)
	else:
		popup.open_with_text("Inventory full")
