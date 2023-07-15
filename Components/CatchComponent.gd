extends Node

@onready var popup = get_tree().get_root().get_node(Settings.UINODEPATH).get_node("InteractionPopup")


func catch(instance):
	var catch_succesful = true # TODO PlayerInventory.add_item(instance.id)
	if catch_succesful:
		instance.queue_free()
		popup.open_with_text("Caught %s" % instance.entityName)
	else:
		popup.open_with_text("Inventory full")
