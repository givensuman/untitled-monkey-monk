extends Area2D

@export var zone_name: String
@onready var audio_manager = get_tree().get_root().get_node("World/AudioManager")

func _ready():
	area_entered.connect(_on_area_entered)
	# Set up collision layer/mask to match player area
	collision_layer = 2
	collision_mask = 2

func _on_area_entered(area: Area2D):
	if area.is_in_group("player"):
		call_deferred("_change_zone")

func _change_zone():
	audio_manager.emit_signal("zone_changed", zone_name)
