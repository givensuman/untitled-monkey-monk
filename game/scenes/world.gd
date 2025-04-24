extends Node2D

@onready var player = $Player

var vines = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for vine in get_children():
		if vine is Area2D and vine.is_in_group("vine"):
			print("Connecting signal for vine:", vine.name)
			 # Connect the vine's area_entered signal to the player's method
			vine.connect("area_entered", Callable(player, "_on_grab_zone_area_entered"))
			vines.append(vine)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
