extends Control

var tutorial_music = preload("res://sounds/music/tutorial_drums.mp3")
@onready var music_player = $MusicPlayer

func _ready():
	$ColorRect/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$ColorRect/VBoxContainer/CreditsButton.pressed.connect(_on_credits_pressed)
	$ColorRect/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$AnimationRect/AnimationPlayer.animation_finished.connect(_on_cutscene_finished)
	$AnimationRect.hide()
	# Start playing the tutorial music
	music_player.stream = tutorial_music
	music_player.play()
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS # Keep playing during scene changes

'''func _on_play_pressed():
	# Change to the main game scene without stopping music
	$Wallpaper1.queue_free()
	$Wallpaper2.queue_free()
	$ColorRect.hide()
	$AnimationRect.show()
	$AnimationRect/AnimationPlayer.play("cutscene")
	if $AnimationRect/AnimationPlayer.animation_finished():
		get_tree().change_scene_to_file("res://game/scenes/world.tscn")'''
		
func _on_play_pressed():
	$Wallpaper1.queue_free()
	$Wallpaper2.queue_free()
	$ColorRect.hide()
	$AnimationRect.show()
	$AnimationRect/AnimationPlayer.play("cutscene")

func _on_cutscene_finished(anim_name):
	if anim_name == "cutscene":
		get_tree().change_scene_to_file("res://game/scenes/world.tscn")


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://game/scenes/credits_screen.tscn")

func _on_quit_pressed():
	get_tree().quit()
