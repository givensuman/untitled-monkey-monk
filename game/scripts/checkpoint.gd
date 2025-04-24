extends Area2D

signal checkpoint_activated

func _ready():
	# Connect both area and body signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	add_to_group("checkpoint")
	# Make sure collision is enabled
	monitoring = true
	monitorable = true

func _on_body_entered(body: Node2D) -> void:
	print("Body entered checkpoint: ", body.name)
	if body.is_in_group("player"):
		body.spawn_position = global_position
		emit_signal("checkpoint_activated")

func _on_area_entered(area: Area2D) -> void:
	print("Area entered checkpoint: ", area.name)
	if area.is_in_group("player"):
		# Get the player node (parent of the area)
		var player = area.get_parent()
		if player and player.is_in_group("player"):
			player.spawn_position = global_position
			emit_signal("checkpoint_activated")
