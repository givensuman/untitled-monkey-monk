extends Area2D

@onready var marker = $Marker2D
@export var end_position = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	end_position = marker.end_position
