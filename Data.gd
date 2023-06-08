extends Node2D

var BUGS : Dictionary
var ITEMS : Dictionary

func _ready():
	BUGS = Utils.read_json_file("res://Critters.json")
	ITEMS = Utils.read_json_file("res://Items.json")
