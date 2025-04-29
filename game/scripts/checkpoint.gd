extends Area2D

signal checkpoint_activated

@onready var checkpoint_sound = $CheckpointSound

func _ready():
	# Connect both area and body signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	add_to_group("checkpoint")
	# Make sure collision is enabled
	monitoring = true
	monitorable = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.update_checkpoint(self):
			checkpoint_sound.play()
		emit_signal("checkpoint_activated")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		# Get the player node (parent of the area)
		var player = area.get_parent()
		if player and player.is_in_group("player"):
			if player.update_checkpoint(self):
				checkpoint_sound.play()
			emit_signal("checkpoint_activated")
