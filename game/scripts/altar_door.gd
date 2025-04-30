extends Node2D

@onready var animation_player = $AnimationPlayer


'''func _on_all_bananas_collected() -> void:
	# Play door opening animation
	print("All bananas collected!")
	animation_player.play("Open")
	#$Sprite2D.frame += 5'''

func _on_area_entered(body: Node2D) -> void:
	if body.is_in_group("player") and GlobalBanana.all_bananas_collected() == true:
		print("All bananas collected, opening door!")
		animation_player.play("Open")
