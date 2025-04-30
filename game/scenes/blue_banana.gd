extends Area2D

@export var color: String = "blue"  # blue, green, or purple
@onready var sprite = $Sprite2D
@onready var collect_sound = $CollectSound

func collect() -> void:
	# Play collection sound
	collect_sound.play()
	
	GlobalBanana.collect_banana()
	
	# Find and animate the corresponding altar
	var altar_name = color.capitalize() + "Altar"
	var altar = get_tree().get_root().get_node_or_null("World/" + altar_name)
	if altar and altar.has_node("AnimationPlayer"):
		altar.get_node("AnimationPlayer").play(color.capitalize() + "_Banana_Altar")
	
	# Hide the banana but wait for sound to finish before removing
	hide()
	await collect_sound.finished
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collect()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		collect()
