extends Node2D

func _ready() -> void:
	$AnimationPlayer.play("golden_banana")
	print($Marker2D.global_position)
