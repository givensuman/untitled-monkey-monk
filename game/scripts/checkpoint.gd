extends Area2D

signal checkpoint_activated

@onready var checkpoint_sound = $CheckpointSound
static var active_checkpoint: Area2D = null

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
		activate_checkpoint(body)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		# Get the player node (parent of the area)
		var player = area.get_parent()
		if player and player.is_in_group("player"):
			activate_checkpoint(player)

func activate_checkpoint(player: Node2D) -> void:
	if player.update_checkpoint(self):
		# Deactivate previous checkpoint if it exists
		if active_checkpoint != null and active_checkpoint != self:
			active_checkpoint.deactivate()
		
		# Set this as the active checkpoint
		active_checkpoint = self
		checkpoint_sound.play()
		$AnimationPlayer.current_animation = "incense"
		$AnimationPlayer.play()
		emit_signal("checkpoint_activated")

func deactivate() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.current_animation = "RESET"
	$AnimationPlayer.play()
