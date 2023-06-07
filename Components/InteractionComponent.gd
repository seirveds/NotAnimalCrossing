extends Node2D

var interactable = false

signal interaction

func _input(event):
	if Input.is_action_just_pressed("interact") and interactable:
		interaction.emit()

func _on_area_entered(area):
	if area.name == "PlayerInteractionArea":
		interactable = true


func _on_area_exited(area):
	interactable = false
