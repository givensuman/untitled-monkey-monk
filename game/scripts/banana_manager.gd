extends Node

signal all_bananas_collected

var blue_banana_collected := false
var green_banana_collected := false
var purple_banana_collected := false

func collect_banana(color: String) -> void:
	match color:
		"blue":
			blue_banana_collected = true
		"green":
			green_banana_collected = true
		"purple":
			purple_banana_collected = true
	
	check_all_collected()

func check_all_collected():
	if blue_banana_collected and green_banana_collected and purple_banana_collected:
		print("All bananas collected, emitting signal!")
		emit_signal("all_bananas_collected")
		return true

func _ready() -> void:
	# Connect to the door to open it when all bananas are collected
	var door = get_tree().get_root().get_node_or_null("World/Altar_Door")
	if door:
		connect("all_bananas_collected", Callable(door, "_on_all_bananas_collected"))
		print("Connected to door successfully")
	else:
		print("Door not found at path World/Altar_Door")
