extends Control

func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/CreditsButton.pressed.connect(_on_credits_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	# Change to the main game scene
	get_tree().change_scene_to_file("res://game/scenes/world.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://game/scenes/credits_screen.tscn")

func _on_quit_pressed():
	get_tree().quit()
