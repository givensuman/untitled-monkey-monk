extends Area2D

@export var zone_name: String
@onready var audio_manager = get_tree().get_root().get_node("World/AudioManager")

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	# Set up collision layer/mask to match player area
	collision_layer = 2
	collision_mask = 2

func _on_area_entered(area: Area2D):
	if area.is_in_group("player"):
		call_deferred("_change_zone")

func _on_area_exited(area: Area2D):
	if area.is_in_group("player"):
		if not _player_in_any_zone():
			audio_manager.emit_signal("zone_changed", "")

func _change_zone():
	audio_manager.emit_signal("zone_changed", zone_name)

func _player_in_any_zone() -> bool:
	# Get the player's area node that actually has the overlapping areas
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return false
	
	var player_area = player.get_node("PlayerArea")
	if not player_area:
		return false
		
	var overlapping = player_area.get_overlapping_areas()
	for area in overlapping:
		if area.has_method("_change_zone"):  # Check if it's a music zone
			return true
	return false
