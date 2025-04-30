extends Node2D

@onready var animation_player = $AnimationPlayer

func _on_all_bananas_collected() -> void:
	# Play door opening animation
	print("All bananas collected!")
	animation_player.play("Open")
	
