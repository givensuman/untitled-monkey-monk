extends Node2D

func _ready() -> void:
	$AnimationPlayer.play("golden_banana")
	print($Marker2D.global_position)
	$Area2D.body_entered.connect(_on_area_2d_body_entered)



	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("character entered")
		get_tree().quit()
