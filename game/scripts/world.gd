extends Node2D

@onready var player = get_node("Player")


func _on_door_collision_body_entered(body: Node2D) -> void:
	if BananaManager.check_all_collected() == true and body.is_in_group("player"):
		player.global_position = Vector2(702, -4584)
