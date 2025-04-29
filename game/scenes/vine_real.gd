extends Area2D

@onready var marker = $Marker2D
@export var end_position = Vector2()
@export var grabbed = false
var player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	end_position = marker.end_position
	#if player != null:
		#if player.vine_grabbed:
			#player.position = end_position
			#player.velocity = Vector2.ZERO
			#player.velocity.x = 0
			#player.velocity.y = 0 
