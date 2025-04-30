extends Area2D

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)  # Add area detection
	set_collision_enabled(false)

func _on_all_bananas_collected() -> void:
	animation_player.play("Open")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Open":
		set_collision_enabled(true)
		print("Door collision enabled")

func set_collision_enabled(enabled: bool) -> void:
	monitoring = enabled
	monitorable = enabled
	print("Door collision set to: ", enabled)

func _on_area_entered(area: Area2D) -> void:
	print("area entered:", area.name)
	if area.is_in_group("player"):
		handle_teleport(area.get_parent())

func _on_body_entered(body: Node2D) -> void:
	print("body entered:", body.name)
	if body.is_in_group("player"):
		handle_teleport(body)

func handle_teleport(body: Node2D) -> void:
	print("handling teleport")
	if BananaManager.check_all_collected():
		print("all bananas collected")
		var world = get_tree().root.get_node("World")
		if world:
			print("found world")
			var gibbon = world.get_node("Gibbon")
			if gibbon and gibbon.has_node("Marker2D"):
				print("found marker")
				body.global_position = gibbon.get_node("Marker2D").global_position
