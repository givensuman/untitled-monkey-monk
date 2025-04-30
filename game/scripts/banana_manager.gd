extends Node

signal all_bananas_collected

var blue_banana_collected := false
var green_banana_collected := false
var purple_banana_collected := false
var door_connected := false

func collect_banana(color: String) -> void:
	match color:
		"blue":
			blue_banana_collected = true
		"green":
			green_banana_collected = true
		"purple":
			purple_banana_collected = true
	
	if check_all_collected():
		if !door_connected:
			connect_to_door()
		emit_signal("all_bananas_collected")

func check_all_collected() -> bool:
	return blue_banana_collected and green_banana_collected and purple_banana_collected

func connect_to_door() -> void:
	var door
	if get_tree() and get_tree().root:
		door = get_tree().root.get_node_or_null("World/Altar_Door")
	if door:
		connect("all_bananas_collected", Callable(door, "_on_all_bananas_collected"))
		door_connected = true

func _ready() -> void:
	await get_tree().process_frame
	connect_to_door()
